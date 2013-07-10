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
            ActiveSupport::Deprecation.warn("No github_id passed to FindOrCreateRepo#find, params: #{params.inspect}") unless params[:github_id]
            query = if params[:github_id]
              { github_id: params[:github_id] }
            else
              { owner_name: params[:owner_name], name: params[:name] }
            end

            run_service(:find_repo, query)
          end

          def create
            ActiveSupport::Deprecation.warn("No github_id passed to FindOrCreateRepo#create, params: #{params.inspect}") unless params[:github_id]
            Repository.create!(:owner_name => params[:owner_name], :name => params[:name], github_id: params[:github_id])
          end
      end
    end
  end
end
