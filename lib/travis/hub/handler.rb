require 'hashr'

module Travis
  class Hub
    class Handler
      attr_reader :event, :payload

      def initialize(event, payload)
        @event = event
        @payload = Hashr.new(payload)
      end
    end
  end
end

