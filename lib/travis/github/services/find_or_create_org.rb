module Travis
  module Github
    module Services
      class FindOrCreateOrg < Travis::Services::Base
        register :github_find_or_create_org

        def run
          find || create
        end

        private

          def find
            ::Organization.where(:login => params[:login]).first
          end

          def create
            Organization.create!(
              :name => data['name'],
              :login => data['login'],
              :github_id => data['id']
            )
          end

          def data
            @data ||= GH["orgs/#{params[:login]}"] || raise(Travis::GithubApiError)
          end
      end
    end
  end
end
