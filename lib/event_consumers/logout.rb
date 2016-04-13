class EventConsumers::Logout < VertxConsumerBase

  def process!
    update_users!( users_without_logged_out_user )
  end


private

  alias_method :logged_out_user, :message_body

  def users_without_logged_out_user
    fetch_users.reject{|u| u == logged_out_user }
  end
end

