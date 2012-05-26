module Travis
  module Api
    module V2
      autoload :Http,    'travis/api/v2/http'
      autoload :Pusher,  'travis/api/v2/pusher'
      autoload :Webhook, 'travis/api/v2/webhook'
    end
  end
end

