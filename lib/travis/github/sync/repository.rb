module Travis
  module Github
    module Sync
      class Repository
        attr_reader :user, :data

        def initialize(user, data)
          @user = user
          @data = data
        end

        def run
          repo = find_or_create
          update!(repo, data)
          permit!(repo) unless permitted?(repo)
          repo
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

          def update!(repo, data)
            repo.update_attributes!(:private => data['private'])
          rescue ActiveRecord::RecordInvalid
            # ignore for now. this seems to happen when multiple syncs (i.e. user sign
            # in requests are running in parallel?
          end

          def owner_name
            data['owner']['login']
          end

          def name
            data['name']
          end
      end
    end
  end
end
