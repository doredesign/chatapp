class RoomsController < ApplicationController
  before_filter :require_current_user

  def show
    @other_users = current_room.users.reject{|u| u == current_user}
  end

  def new
    @room = Room.new
  end

  def create
    new_room = Room.create(name: params[:room][:name])
    redirect_to room_path(new_room.name)
  end

  def default
    redirect_to room_path(default_room.name)
  end

private

  def default_room
    Room.first_or_create(name: 'home')
  end

  def current_room
    @current_room ||= Room.find_by(name: params[:name])
  end
  helper_method :current_room

  def require_current_user
    redirect_to new_session_path unless current_user
  end
end
