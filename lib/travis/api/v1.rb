module Travis
  module Api
    module V1
      autoload :Archive, 'travis/api/v1/archive'
      autoload :Http,    'travis/api/v1/http'
      autoload :Pusher,  'travis/api/v1/pusher'
      autoload :Webhook, 'travis/api/v1/webhook'
    end
  end
end
