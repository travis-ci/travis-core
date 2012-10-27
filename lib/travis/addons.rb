module Travis
  module Addons
    autoload :Campfire,     'travis/addons/campfire'
    autoload :Email,        'travis/addons/email'
    autoload :Flowdock,     'travis/addons/flowdock'
    autoload :GithubStatus, 'travis/addons/github_status'
    autoload :Hipchat,      'travis/addons/hipchat'
    autoload :Irc,          'travis/addons/irc'
    autoload :Pusher,       'travis/addons/pusher'
    autoload :Util,         'travis/addons/util'
    autoload :Webhook,      'travis/addons/webhook'

    constants.each do |name|
      key = name.to_s.underscore
      const = const_get(name).const_get(:EventHandler) rescue nil
      Travis::Event::Subscription.register(key, const) if const
    end
  end
end
