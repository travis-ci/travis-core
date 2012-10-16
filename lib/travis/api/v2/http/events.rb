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
                'source_id' => source(event).id,
                'source_type' => source(event).class.name,
                'event' => event.event,
                'data' => event.data,
                'created_at' => format_date(event.created_at)
              }
            end

            def source(event)
              case event.source
              when Request
                event.source.commit
              else
                event.source
              end
            end
        end
      end
    end
  end
end

