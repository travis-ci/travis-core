require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      class FindAll < Base
        def run
          result
        end

        def updated_at
          result.maximum(:updated_at)
        end

        private

          def result
            @result ||= params[:ids] ? by_ids : by_params
          end

          def by_ids
            scope(:build).where(:id => params[:ids])
          end

          def by_params
            repo ? repo.last_finished_builds_by_branches : scope(:build).none
          end

          def repo
            @repo ||= service(:repositories, :find_one, params).run
          end
      end
    end
  end
end
