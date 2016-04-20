if ENV['eventbus']
  Pathname.glob('lib/event_consumers/*').each do |pathname|
    file_name_with_ext = pathname.basename.to_s # e.g. login.rb
    class_string = file_name_with_ext.split('.').first.titleize # e.g. Login
    "EventConsumers::#{class_string}".constantize.register!
  end
end
