require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      class All < Base
        def run
          repository = scope(:repository).find_by(params)
          repository ? repository.last_finished_builds_by_branches : scope(:build).none
        end
      end
    end
  end
end
