class SessionsController < ApplicationController
  before_action :find_or_create_user, only: :create

  def new
  end

  def create
    session[:user_id] = @user.id
    redirect_to(params[:return_to] || root_path)
  end

  def destroy
    session[:user_id] = nil
    redirect_to(root_path)
  end

  private

  def find_or_create_user
    @user = User.find_or_create_by(name: params[:name])
  end
end
