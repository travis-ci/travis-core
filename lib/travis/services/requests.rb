module Travis
  module Services
    module Requests
      autoload :Payload, 'travis/services/requests/payload'
      autoload :Receive, 'travis/services/requests/receive'
      autoload :Requeue, 'travis/services/requests/requeue'
    end
  end
end

