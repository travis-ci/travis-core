class Repository
  class Sync
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def run
      user.authenticated_on_github do
        Travis::Github.repositories_for(user).each do |data|
          user.repositories << repo(data)
        end
      end
    end

    private

      def repo(data)
        # This currently does not link the repository to its owner because looking
        # up the owner type requires an additional request to the github api.
        Repository.find_or_create_by_owner_name_and_name(data['owner']['login'], data['name'])
      end
  end
end
