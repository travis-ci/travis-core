require 'travis/services'

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
            ::Organization.where(:github_id => params[:github_id]).first.tap do |organization|
              if organization
                login = params[:login] || data['login']
                if organization.login != login
                  organization.update_attributes(login: login)
                  Repository.where(owner_id: organization.id, owner_type: ::Organization).
                             update_all(owner_name: login)
                end

                nullify_logins(organization.github_id, organization.login)
              end
            end
          end

          def nullify_logins(github_id, login)
            users = User.where(["login = ?", login])
            if users.exists?
              Travis.logger.info("About to nullify login (#{login}) for users: #{users.map(&:id).join(', ')}")
              users.update_all(login: nil)
            end

            organizations = Organization.where(["github_id <> ? AND login = ?", github_id, login])
            if organizations.exists?
              Travis.logger.info("About to nullify login (#{login}) for organizations: #{organizations.map(&:id).join(', ')}")
              organizations.update_all(login: nil)
            end
          end

          def create
            organization = Organization.create!(
              :name => data['name'],
              :login => data['login'],
              :github_id => data['id']
            )

            nullify_logins(organization.github_id, organization.login)

            organization
          end

          def data
            @data ||= GH["orgs/#{params[:login]}"] || raise(Travis::GithubApiError)
          end
      end
    end
  end
end
