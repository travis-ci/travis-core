module Travis
  module Services
    class Builds
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

        def by_event_type(params)
          repository(params).builds.by_event_type(params[:event_type])
        end

        def repository(params)
          Repository.find(params[:repository_id])
        end
    end
  end
end
