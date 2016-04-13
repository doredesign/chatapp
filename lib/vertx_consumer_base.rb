class VertxConsumerBase
  IncompleteSubclass = Class.new( StandardError )

  CHAT_MAP_KEY = "chat"
  USERS_DATA_KEY = "users"
  NEW_USER_CHANNEL = "new_user"

  class << self
    delegate :vertx, :to => Jubilee
    delegate :event_bus, :shared_data, to: :vertx
  end

  def self.chat_data
    @chat_data ||= shared_data.get_local_map(CHAT_MAP_KEY)
  end

  def self.register!
    event_bus.consumer( demodulized_class_name.downcase ) do |message|
      new(message).process!
    end
  end

  def self.demodulized_class_name
    name.demodulize
  end


  def initialize(message)
    @message = message
    @message_body = message.body
  end

  def process!
    raise IncompleteSubclass, "#{self.class.name} must implement a method called `process!`"
  end


private

  delegate :event_bus, :chat_data, to: :class
  attr_reader :message_body

  def reply(reply_hash)
    @message.reply(reply_hash)
  end

  def fetch_users
    chat_data.get(USERS_DATA_KEY)
  end

  def update_users!(new_users)
    chat_data.put(USERS_DATA_KEY, new_users)
  end

  def publish_new_user(new_user)
    event_bus.publish(NEW_USER_CHANNEL, new_user)
  end
end
