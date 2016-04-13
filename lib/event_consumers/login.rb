class EventConsumers::Login < VertxConsumerBase

  def process!
    reply(users: original_users)
    add_new_user!
    publish_new_user(new_user)
  end


private

  alias_method :new_user, :message_body

# TODO: dedupe new_users
  def add_new_user!
    new_users = original_users + [new_user]
    update_users!(new_users)
  end

  def original_users
    @original_users ||= fetch_users || []
  end
end
