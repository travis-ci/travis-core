require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      class All < Base
        def run
          params[:ids] ? by_ids : by_params
        end

        private

          def by_ids
            scope(:build).where(:id => params[:ids])
          end

          def by_params
            repo ? repo.last_finished_builds_by_branches : scope(:build).none
          end

          def repo
            @repo ||= service(:repositories, :one, params).run
          end
      end
    end
  end
end
