class Repository
  class Sync
    class Repository
      attr_reader :user, :data

      def initialize(user, data)
        @user = user
        @data = data
      end

      def run
        repo = find_or_create
        repo.update_attributes!(:private => data['private'])
        permit!(repo) unless permitted?(repo)
      end

      private

        def find_or_create
          ::Repository.find_or_create_by_owner_name_and_name(owner_name, name)
        end

        def permitted?(repo)
          user.repositories.include?(repo)
        end

        def permit!(repo)
          user.permissions.create!(
            :user => user,
            :repository => repo,
            :admin => data['permissions']['admin']
          )
        end

        def owner_name
          data['owner']['login']
        end

        def name
          data['name']
        end
    end

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def run
      user.authenticated_on_github do
        Travis::Github.repositories_for(user).each do |data|
          Repository.new(user, data).run
        end
      end
    end
  end
end
