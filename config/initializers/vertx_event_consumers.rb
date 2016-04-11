# Call register! on each class in lib/event_consumers
Pathname.glob('lib/event_consumers/*').each do |pathname|
  file_name_with_ext = pathname.basename.to_s
  class_string = file_name_with_ext.split('.').first.titleize
  "EventConsumers::#{class_string}".constantize.register!
end
