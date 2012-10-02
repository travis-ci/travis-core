module Travis
  module Services
    module Repositories
      class One < Base
        def run(options = {})
          repository = scope(:repository).find_by(params)
          raise(ActiveRecord::RecordNotFound) if repository.nil? && !options[:raise].is_a?(FalseClass)
          repository
        end
      end
    end
  end
end
