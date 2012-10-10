module Travis
  module Services
    module Repositories
      class ByGithub < Base
        def run
          repo = find || create
          repo.update_attributes(params)
          repo
        end

        private

          def find
            service(:repositories, :one, params).run
          end

          def create
            Repository.create!(:owner_name => params[:owner_name], :name => params[:name])
          end
      end
    end
  end
end


