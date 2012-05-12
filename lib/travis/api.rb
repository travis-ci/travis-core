module Travis
  module Api
    autoload :Archive, 'travis/api/archive'
    autoload :Formats, 'travis/api/formats'
    autoload :Http,    'travis/api/http'
    autoload :Pusher,  'travis/api/pusher'
    autoload :Webhook, 'travis/api/webhook'
    autoload :Worker,  'travis/api/worker'
  end
end
