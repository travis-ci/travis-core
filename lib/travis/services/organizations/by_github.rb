module Travis
  module Services
    module Organizations
      class ByGithub < Base
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
