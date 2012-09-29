require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Builds
      class All < Base
        def run
          # TODO :after_number seems like a bizarre api
          # why not just pass an id? pagination style?
          builds = by_event_type(params)
          params[:after_number] ? builds.older_than(params[:after_number]) : builds.recent
        rescue ActiveRecord::RecordNotFound
          scope(:build).none
        end

        private

          def by_event_type(params)
            repository(params).builds.by_event_type(params[:event_type])
          end

          def repository(params)
            scope(:repository).find_by(params) || raise(ActiveRecord::RecordNotFound)
          end
      end
    end
  end
end
