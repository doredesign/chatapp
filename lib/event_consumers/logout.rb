class EventConsumers::Logout < VertxConsumerBase
  def process!
    remove_user_from_rooms!
  end


private

  def remove_user_from_rooms!
    user.rooms = []
  end
end

