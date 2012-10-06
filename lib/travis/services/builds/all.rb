require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Builds
      class All < Base
        def run
          params[:ids] ? by_ids : by_params
        end

        private

          def by_ids
            scope(:build).where(:id => params[:ids])
          end

          def by_params
            if repo
              # TODO :after_number seems like a bizarre api
              # why not just pass an id? pagination style?
              builds = repo.builds.descending
              builds = builds.by_event_type(params) if params[:event_type]
              params[:after_number] ? builds.older_than(params[:after_number]) : builds.recent
            else
              scope(:build).none
            end
          end

          def repo
            @repo ||= service(:repositories, :one, params).run
          end
      end
    end
  end
end
