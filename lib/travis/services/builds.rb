module Travis
  module Services
    class Builds < Base
      def find_all(params = {})
        # TODO :after_number seems like a bizarre api
        # why not just pass an id? pagination style?
        builds = by_event_type(params)
        params[:after_number] ? builds.older_than(params[:after_number]) : builds.recent
      end

      def find_one(params)
        scope = params[:repository_id] ? repository(params).builds : build_scope
        scope.includes(:commit, :matrix => [:commit, :log]).find(params[:id])
      end

      protected

        def by_event_type(params)
          repository(params).builds.by_event_type(params[:event_type])
        end

        def repository(params)
          repository_scope.find(params[:repository_id])
        end

        def build_scope
          Build
        end

        def repository_scope
          Repository
        end
    end
  end
end
