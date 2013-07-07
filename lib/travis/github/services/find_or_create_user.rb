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
                if user.login != params[:login]
                  user.update_attributes(params.slice(:login))
                  Repository.where(owner_id: user.id, owner_type: 'User').update_all(owner_name: params[:login])
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
            User.where(["github_id <> ? AND login = ?", github_id, login]).update_all(login: nil)
            Organization.where(["login = ?", login]).update_all(login: nil)
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
