module Travis
  module Github
    module Services
      class FindOrCreateRepo < Travis::Services::Base
        register :github_find_or_create_repo

        def run
          repo = find || create
          repo.update_attributes(params)
          repo
        end

        private

          def find
            Travis.run_service(:find_repository, params)
          end

          def create
            Repository.create!(:owner_name => params[:owner_name], :name => params[:name])
          end
      end
    end
  end
end
