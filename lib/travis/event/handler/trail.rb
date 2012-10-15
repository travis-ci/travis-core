module Travis
  module Event
    class Handler
      class Trail < Handler
        EVENTS = [/^((?!event|log|worker).)*$/] # i.e. does not include "log"

        def handle?
          true
        end

        def handle
          ::Event.create!(:source => object, :repository => repository, :event => event, :data => data)
        end

        private

          def repository
            object.is_a?(Repository) ? object : object.repository
          end

          def data
            data = {}
            data[:result]  = object.result  if object.respond_to?(:result)
            data[:message] = object.messaeg if object.respond_to?(:message)
            data
          end
      end
    end
  end
end
