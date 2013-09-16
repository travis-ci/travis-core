module Travis
  module Api
    module V1
      autoload :Http,    'travis/api/v1/http'
      autoload :Helpers, 'travis/api/v1/helpers'
      autoload :Webhook, 'travis/api/v1/webhook'
    end
  end
end
