module Travis
  module Api
    module V2
      module Http
        class Events
          include Formats

          attr_reader :events, :options

          def initialize(events, options = {})
            @events = events
            @options = options
          end

          def data
            {
              'events' => events.map { |event| event_data(event) }
            }
          end

          private

            def event_data(event)
              {
                'id' => event.id,
                'repository_id' => event.repository_id,
                'source_id' => event.source_id,
                'source_type' => event.source_type,
                'data' => event.data
              }
            end
        end
      end
    end
  end
end

