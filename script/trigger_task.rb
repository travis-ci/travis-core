require 'travis'
require 'active_support/core_ext/string/inflections'

id, type = ARGV
data = {} # ?

Travis::Database.connect
Travis::Task.run_local = true

Travis.config.notifications = [type]
Travis::Event::SUBSCRIBERS.clear

begin
  handler = Travis::Addons.const_get(type.camelize)::EventHandler
  handler.notify('build:finished', Build.find(id), data)
rescue Exception => e
  puts e.message, e.backtrace
end
