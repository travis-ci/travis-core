module Travis
  class Service
    class Builds < Service
      def find_all(params)
        # TODO :after_number seems like a bizarre api
        # why not just pass an id? pagination style?
        builds = by_event_type(params)
        params[:after_number] ? builds.older_than(params[:after_number]) : builds.recent
      end

      def find_one(params)
        scope = params[:repository_id] ? repository(params).builds : Build
        scope.includes(:commit, :matrix => [:commit, :log]).find(params[:id])
      end

      private

        def repository(params)
          service(:repositories).find_one(params.slice(:repository_id)) || raise(ActiveRecord::RecordNotFound)
        end

        def by_event_type(params)
          repository(params).builds.by_event_type(params[:event_type])
        end
    end
  end
end
