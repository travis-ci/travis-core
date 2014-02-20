module Travis
  module Api
    module V2
      module Http
        class Requests
          include Formats
          attr_reader :requests, :options

          def initialize(requests, options = {})
            @requests = requests
            @options = options
          end

          def data
            {
              'requests' => requests.map { |request| request_data(request) },
            }
          end

          private

            def request_data(request)
              {
                'id' => request.id,
                'repository_id' => request.repository_id,
                'commit_id' => request.commit_id,
                'created_at' => format_date(request.created_at),
                'owner_id' => request.owner_id,
                'owner_type' => request.owner_type,
                'event_type' => request.event_type,
                'base_commit' => request.base_commit,
                'head_commit' => request.head_commit,
                'result' => request.result,
                'message' => request.message
              }
            end
        end
      end
    end
  end
end
