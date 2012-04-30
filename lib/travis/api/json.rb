module Travis
  module Api
    module Json
      autoload :Archive, 'travis/api/json/archive'
      autoload :Formats, 'travis/api/json/formats'
      autoload :Http,    'travis/api/json/http'
      autoload :Pusher,  'travis/api/json/pusher'
      autoload :Webhook, 'travis/api/json/webhook'
      autoload :Worker,  'travis/api/json/worker'
    end
  end
end

