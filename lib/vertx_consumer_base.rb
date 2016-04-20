class VertxConsumerBase
  IncompleteSubclass = Class.new( StandardError )

  class << self
    delegate :vertx, :to => Jubilee
    delegate :event_bus, to: :vertx
  end

  def self.register!
    event_bus.consumer( demodulized_class_name.downcase ) do |message|
      new(message).process!
    end
  end

  def self.demodulized_class_name
    name.demodulize
  end


  attr_reader :message_body

  def initialize(message)
    @message_body = message.body
  end

  def process!
    raise IncompleteSubclass, "#{self.class.name} must implement a method called `process!`"
  end

  def user
    User.find_by(name: message_body.sender)
  end

  def room
    Room.find_by(name: message_body.room)
  end
end
