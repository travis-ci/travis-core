require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Builds
      class One < Base
        def run
          scope = params[:repository_id] ? repository(params).builds : scope(:build)
          scope.includes(:commit, :matrix => [:commit, :log]).find(params[:id])
        end

        private

          def repository(params)
            scope(:repository).find_by(params) || raise(ActiveRecord::RecordNotFound)
          end
      end
    end
  end
end
