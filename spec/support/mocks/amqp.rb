module Support
  module Mocks
    module Amqp
      class Publisher
        attr_accessor :messages

        def initialize
          @messages = []
        end

        def publish(*args)
          messages << args
        end

        def reset!
          @messages = []
        end
        alias :clear! :reset!
      end
    end
  end
end

