module Travis
  module Services
    class Branches < Base
      def find_all(params = {})
        repository = scope(:repository).find_by(params)
        repository ? repository.last_finished_builds_by_branches : scope(:build).none
      end
    end
  end
end
