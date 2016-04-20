class EventConsumers::Login < VertxConsumerBase
  def process!
    add_user_to_room!
  end

private

  def add_user_to_room!
    user.rooms = [room]
  end
end
