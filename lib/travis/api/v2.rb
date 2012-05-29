module Travis
  module Api
    module V2
      autoload :Http,   'travis/api/v2/http'
      autoload :Event,  'travis/api/v2/event'
      autoload :Pusher, 'travis/api/v2/pusher'
    end
  end
end

