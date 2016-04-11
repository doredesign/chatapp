class EventConsumers::Logout < VertxConsumerBase
  def self.register!
    event_bus.consumer('logout') do |message|
      chat_data = shared_data.get_local_map("chat")
      users = to_a(chat_data.get("users"))
      users.reject!{|u| u == message.body }
      chat_data.put("users", users.join("\0"))
    end
  end
end

