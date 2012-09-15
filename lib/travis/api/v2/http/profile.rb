module Travis
  module Api
    module V2
      module Http
        class Profile
          include Formats

          attr_reader :user, :accounts, :repository_counts, :options

          def initialize(data, options = {})
            @user, @accounts, @repository_counts = data.values_at(:user, :accounts, :repository_counts)
            @options = options
          end

          def data
            {
              'profile' => profile_data,
              'accounts' => accounts.map { |account| account_data(account) }
            }
          end

          private

            def profile_data
              {
                'id' => user.id,
                'name' => user.name,
                'login' => user.login,
                'email' => user.email,
                'gravatar_id' => user.gravatar_id,
                'locale' => user.locale,
                'is_syncing' => user.syncing?,
                'synced_at' => format_date(user.synced_at)
              }
            end

            def account_data(account)
              {
                'id' => account.id,
                'name' => account.name,
                'login' => account.login,
                'type' => account.is_a?(::User) ? 'user' : 'org',
                'reposCount' => repository_counts[account.login]
              }
            end
        end
      end
    end
  end
end


