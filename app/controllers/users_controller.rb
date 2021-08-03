class UsersController < ApplicationController
  def new
  end

  def create
    validate_add_users
    redirect_to users_list_path
  end

  def list
    @users = session[SESSION_KEYS['user_list']].values rescue []
  end

  private

  def add_users
    session[SESSION_KEYS['user_list']][params[:mobile]] = {}
    session[SESSION_KEYS['user_list']][params[:mobile]][:name] = params[:name]
    session[SESSION_KEYS['user_list']][params[:mobile]][:age] = params[:age]
    session[SESSION_KEYS['user_list']][params[:mobile]][:gender] = params[:gender]
    session[SESSION_KEYS['user_list']][params[:mobile]][:mobile] = params[:mobile]
    session[SESSION_KEYS['user_list']][params[:mobile]][:address] = params[:address]
  end

  def validate_add_users
    session[SESSION_KEYS['user_list']] = {} if session[SESSION_KEYS['user_list']].nil?
    if session[SESSION_KEYS['user_list']][params[:mobile]].blank?
      add_users
      return session[SESSION_KEYS['user_list']][params[:mobile]]
    else
    #user already exist with same mobile
      return session[SESSION_KEYS['user_list']][params[:mobile]]
    end
  end
end
