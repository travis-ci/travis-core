module Travis
  module Api
    module V2
      module Http
        class User
          include Formats

          attr_reader :user, :options

          def initialize(user, options = {})
            @user = user
            @options = options
          end

          def data
            {
              'user' => user_data(user)
            }
          end

          private

            def user_data(user)
              {
                'login' => user.login,
                'name' => user.name,
                'email' => user.email,
                'gravatar_id' => user.gravatar_id,
                'locale' => user.locale,
                'is_syncing' => user.is_syncing,
                'synced_at' => format_date(user.synced_at)
              }
            end
        end
      end
    end
  end
end


