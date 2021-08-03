class VehicleController < ApplicationController
  def new
    users = session[SESSION_KEYS['user_list']].values rescue []
    @user_mobile = users.map{|s| [s['name'], s['mobile']]} if users.present?
  end

  def create
    validate_add_vehicles
    redirect_to vehicle_list_path
  end

  def list
    @vehicles = session[SESSION_KEYS['vehicle_list']].values rescue []
    @users = session[SESSION_KEYS['user_list']] rescue {} if @vehicles.present?
  end
  private

  def add_vehicles
    session[SESSION_KEYS['vehicle_list']][params[:no]] = {}
    session[SESSION_KEYS['vehicle_list']][params[:no]][:reg_no] = params[:no]
    session[SESSION_KEYS['vehicle_list']][params[:no]][:user_mobile] = params[:user_mobile]
    session[SESSION_KEYS['vehicle_list']][params[:no]][:brand] = params[:brand]
    session[SESSION_KEYS['vehicle_list']][params[:no]][:no_of_wheels] = params[:no_of_wheels].to_i
    session[SESSION_KEYS['vehicle_list']][params[:no]][:ac] = params[:ac]
    session[SESSION_KEYS['vehicle_list']][params[:no]][:seats] = params[:seats].to_i
  end

  def validate_add_vehicles
    session[SESSION_KEYS['vehicle_list']] = {} if session[SESSION_KEYS['vehicle_list']].nil?
    if session[SESSION_KEYS['vehicle_list']][params[:no]].blank?
      add_vehicles
      return session[SESSION_KEYS['vehicle_list']][params[:no]]
    else
      #vehicle already exist with same no
      return session[SESSION_KEYS['vehicle_list']][params[:no]]
    end
  end
end
