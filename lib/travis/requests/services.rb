module Travis
  module Requests
    module Services
      autoload :Receive, 'travis/requests/services/receive'
      autoload :Requeue, 'travis/requests/services/requeue'

      class << self
        def register
          constants(false).each do |name|
            Travis.services.add(name.to_s.underscore, const_get(name))
          end
        end
      end
    end
  end
end
