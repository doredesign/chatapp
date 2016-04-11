class MessagesController < ApplicationController
  before_filter :require_current_user

  def index
  end

  private

  def require_current_user
    redirect_to new_session_path unless current_user
  end
end
