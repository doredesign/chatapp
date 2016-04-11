class EventConsumers::Login < VertxConsumerBase
  def self.register!
    event_bus.consumer('login') do |message|
      user = message.body
      chat_data = shared_data.get_local_map("chat")
      users = chat_data.get("users") || ""
      message.reply(users: to_a(users))
      users = user + "\0" + users
      chat_data.put("users", users)
      event_bus.publish("new_user", user)
    end
  end
end
