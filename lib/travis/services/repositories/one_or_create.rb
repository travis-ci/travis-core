module Travis
  module Services
    module Repositories
      class OneOrCreate < Base
        def run
          service(:repositories, :one, params).run
        rescue ActiveRecord::RecordNotFound
          scope(:repository).create!(params.slice(:owner_name, :name))
        end
      end
    end
  end
end
