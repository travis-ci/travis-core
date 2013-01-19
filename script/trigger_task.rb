require 'travis'
require 'active_support/core_ext/string/inflections'

id, type = ARGV
data = {} # ?

Travis::Database.connect
Travis::Task.run_local = true
Travis.config.notifications = [type]

Travis::Event::SUBSCRIBERS.clear
Travis::Event.subscribers

handler = Travis::Addons.const_get(type.camelize)::EventHandler
handler.notify('finished', Build.find(id), data)
