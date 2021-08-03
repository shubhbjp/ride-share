class RideController < ApplicationController

  def new
    @vehicles_list = session[SESSION_KEYS['vehicle_list']] rescue []
    @users_list = session[SESSION_KEYS['user_list']] rescue []
  end

  def create
    available_seats, user_mobile = get_available_seats(params['vehicle_no'])
    available_seats = params['available_seats'].to_i <= available_seats.to_i ? params['available_seats'].to_i : available_seats.to_i 
    ride = offer_ride(params['vehicle_no'], params['src'], params['dest'],available_seats, user_mobile)
  end

  def list
    src=params['src'] || ''
    dest=params['dest'] || ''
    users = session[SESSION_KEYS['user_list']].values rescue []
    @user_mobile = users.map{|s| [s['name'], s['mobile']]} if users.present?
    if src.present? && dest.present?
      @offered_rides = session[SESSION_KEYS['offer_ride']].select{|s| s['src'] == src && s['dest'] == dest && s['is_active'] == true}.sort_by{|o| o['available_seats']}.reverse
    elsif src.present? && dest.blank?
      @offered_rides = session[SESSION_KEYS['offer_ride']].select{|s| s['src'] == src && s['is_active'] == true}.sort_by{|o| o['available_seats']}.reverse
    elsif src.blank? && dest.present?
      @offered_rides = session[SESSION_KEYS['offer_ride']].select{|s| s['dest'] == dest && s['is_active'] == true}.sort_by{|o| o['available_seats']}.reverse
    else
      @offered_rides = session[SESSION_KEYS['offer_ride']].select{|s| s['is_active'] == true}.sort_by{|o| o['available_seats']}.reverse
    end
  end

  def select
    ride = session[SESSION_KEYS['offer_ride']].select{|s| s['id'].to_i == params['id'].to_i && s['is_active'] == true}.try(:last) rescue []
    if ride.present?
      begin
        already_booked_seats = 0
        session[SESSION_KEYS['selected_ride']].each do |a|
          already_booked_seats += a[1] if a[0].to_i == ride['id'].to_i
        end
      rescue Exception => e
        already_booked_seats = 0
      end
      available_seats = ride["available_seats"].to_i - already_booked_seats.to_i
      if available_seats >= params["seats"].to_i && available_seats > 0 && params["seats"].to_i > 0
        save_selected_ride_in_session(ride['id'].to_i, params['seats'].to_i, params['user_mobile'].to_i)
        @message = "Ride Successfully booked for #{params['seats']} passengers #{session[SESSION_KEYS['selected_ride']]}"
      elsif available_seats.to_i > 0 && params['seats'].to_i > 0
        @message = "Ride Not Booked. Only #{available_seats} passengers are allowed to book"
      else
        @message = "Ride Not Booked. All Available seats are full"
      end
    else
      @message = "Selected Ride not offered now"
    end
    p "========== #{session[SESSION_KEYS['selected_ride']]} #{session[SESSION_KEYS['selected_ride']].class} =========="
  end

  def end
    session[SESSION_KEYS['offer_ride']].each do |s| 
      s["is_active"] = false if s['id'].to_i == params['id'].to_i
    end
    redirect_to ride_list_path
  end

  def stats
    users = session[SESSION_KEYS['user_list']].values rescue []
    @stats = []
    users.each do |u|
      @stats << {name: u['name'], taken: session[SESSION_KEYS['selected_ride']].select {|a| a[2].to_i == u["mobile"].to_i}.size, offered: session[SESSION_KEYS['offer_ride']].select {|a| a['user_mobile'].to_i == u["mobile"].to_i}.size}
    end
  end 

  private

  def get_available_seats(vehicle_no)
    if session[SESSION_KEYS['vehicle_list']][vehicle_no].present?
      return session[SESSION_KEYS['vehicle_list']][vehicle_no]['seats'], session[SESSION_KEYS['vehicle_list']][vehicle_no]['user_mobile']
    else
      #no vehicle no found in the db
      return 0, 0
    end
  end

  def offer_ride(vehicle_no='', src='', dest='', available_seats=0, user_mobile=0)
    return if src == '' || dest == '' || available_seats.to_i == 0 || vehicle_no == '' || user_mobile == 0
    session[SESSION_KEYS['offer_ride']] = [] if session[SESSION_KEYS['offer_ride']].nil?
    ride = session[SESSION_KEYS['offer_ride']].select{|s| s['vehicle_no'] == vehicle_no && s['is_active'] == true}
    if ride.present?
      @message = "Ride Already Exist: #{ride.last}"
    else
      ride = {id: session[SESSION_KEYS['offer_ride']].size+1, vehicle_no: vehicle_no, src: src, dest: dest, available_seats: available_seats, is_active: true, user_mobile:user_mobile, created_at: Time.now}
      session[SESSION_KEYS['offer_ride']] << ride
      @message = "Ride Created #{ride}"
    end
  end

  def save_selected_ride_in_session(ride_id,seats,user_mobile)
    return if ride_id.to_i == 0 || seats.to_i == 0
    session[SESSION_KEYS['selected_ride']] = [] if session[SESSION_KEYS['selected_ride']].nil?
    session[SESSION_KEYS['selected_ride']].push([ride_id,seats,user_mobile])
  end
end
