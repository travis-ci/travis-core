require 'core_ext/active_record/none_scope'

module Travis
  module Services
    class Branches < Base
      def find_all(params = {})
        return find_by_ids(params) if params.key?(:ids)
        repository = scope(:repository).find_by(params)
        repository ? repository.last_finished_builds_by_branches : scope(:build).none
      end

      def find_by_ids(params)
        scope(:build).where(:id => params[:ids])
      end
    end
  end
end
