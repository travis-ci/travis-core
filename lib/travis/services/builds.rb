require 'core_ext/active_record/none_scope'

module Travis
  module Services
    class Builds < Base
      def find_all(params = {})
        # TODO :after_number seems like a bizarre api
        # why not just pass an id? pagination style?
        builds = by_event_type(params)
        params[:after_number] ? builds.older_than(params[:after_number]) : builds.recent
      rescue ActiveRecord::RecordNotFound
        scope(:build).none
      end

      def find_one(params)
        scope = params[:repository_id] ? repository(params).builds : scope(:build)
        scope.includes(:commit, :matrix => [:commit, :log]).find(params[:id])
      end

      protected

        def by_event_type(params)
          repository(params).builds.by_event_type(params[:event_type])
        end

        def repository(params)
          scope(:repository).find_by(params) || raise(ActiveRecord::RecordNotFound)
        end
    end
  end
end
