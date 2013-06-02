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
              if user.login != params[:login]
                user.update_attributes(params.slice(:login))
                user.repositories.each do |repository|
                  repository.update_attributes(owner_name: params[:login])
                end
              end
            end
          end

          def create
            User.create!(
              :name => data['name'],
              :login => data['login'],
              :email => data['email'],
              :github_id => data['id'],
              :gravatar_id => data['gravatar_id']
            )
          end

          def data
            unless defined?(@data)
              if params[:github_id]
                @data ||= GH["user/#{params[:github_id]}"] || raise(Travis::GithubApiError)
              else
                @data ||= GH["users/#{params[:login]}"] || raise(Travis::GithubApiError)
              end
            end

            @data
          end
      end
    end
  end
end
