module Travis
  module Services
    module Requests
      autoload :Receive, 'travis/services/requests/receive'
      autoload :Requeue, 'travis/services/requests/requeue'
    end
  end
end

