module Support
  module Mocks
    module Pusher
      class Channel
        attr_accessor :messages

        def initialize
          @messages = []
        end

        def trigger(*args)
          messages << args
        end
        alias :trigger_async :trigger

        def reset!
          @messages = []
        end
        alias :clear! :reset!
      end
    end
  end
end
