module Travis
  module Github
    module Services
      class FindOrCreateUser < Travis::Services::Base
        register :github_find_or_create_user

        def run
          find || create
        end

        private

          def find
            ::User.where(github_id: params[:github_id]).first.tap do |user|
              if user
                ActiveRecord::Base.transaction do
                  login = params[:login] || data['login']
                  if user.login != login
                    Repository.where(owner_name: user.login).
                               update_all(owner_name: login)
                    user.update_attributes(login: login)
                  end
                end

                nullify_logins(user.github_id, user.login)
              end
            end
          end

          def create
            user = User.create!(
              :name => data['name'],
              :login => data['login'],
              :email => data['email'],
              :github_id => data['id'],
              :gravatar_id => data['gravatar_id']
            )

            nullify_logins(user.github_id, user.login)

            user
          end

          def nullify_logins(github_id, login)
            users = User.where(["github_id <> ? AND login = ?", github_id, login])
            if users.exists?
              Travis.logger.info("About to nullify login (#{login}) for users: #{users.map(&:id).join(', ')}")
              users.update_all(login: nil)
            end

            organizations = Organization.where(["login = ?", login])
            if organizations.exists?
              Travis.logger.info("About to nullify login (#{login}) for organizations: #{organizations.map(&:id).join(', ')}")
              organizations.update_all(login: nil)
            end
          end

          def data
            @data ||= fetch_data
          end

          def fetch_data
            if params[:github_id]
              GH["user/#{params[:github_id]}"] || raise(Travis::GithubApiError)
            else
              GH["users/#{params[:login]}"] || raise(Travis::GithubApiError)
            end
          end
      end
    end
  end
end
