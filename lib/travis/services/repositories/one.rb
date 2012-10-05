module Travis
  module Services
    module Repositories
      class One < Base
        def run(options = {})
          scope(:repository).find_by(params)
        end
      end
    end
  end
end
