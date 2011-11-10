module Travis
  module Notifications
    class Payload
      def to_hash
        render(:hash)
      end
    end
  end
end
