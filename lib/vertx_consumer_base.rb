class VertxConsumerBase
  def self.vertx
    Jubilee.vertx
  end

  def self.event_bus
    @event_bus ||= vertx.event_bus
  end

  def self.shared_data
    @shared_data ||= vertx.shared_data
  end

  def self.to_a(users)
    users.split("\0")
  end
end
