module Travis
  module Requests
    module Services
      autoload :Receive, 'travis/requests/services/receive'
      autoload :Requeue, 'travis/requests/services/requeue'

      class << self
        def register
          Travis.services.add(
            receive_request: Receive,
            requeue_request: Requeue
          )
        end
      end
    end
  end
end
