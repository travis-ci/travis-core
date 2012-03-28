require 'github'

class Request
  module Payload
    # Adds `attributes` and `reject?` methods to a github servicehook payload.
    # These are used in `Request.create_from`.
    class Github < ::Github::ServiceHook::Payload
      def initialize(data, token)
        super(data)
        self.token = token
      end

      def attributes
        { :source => source, :payload => payload, :commit => last_commit.try(:to_hash), :token => token }
      end
    end
  end
end
