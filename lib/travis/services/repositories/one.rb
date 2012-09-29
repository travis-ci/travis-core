module Travis
  module Services
    module Repositories
      class One < Base
        def run
          scope(:repository).find_by(params) || raise(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
