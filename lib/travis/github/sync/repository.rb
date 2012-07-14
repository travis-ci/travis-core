module Travis
  module Github
    module Sync
      class Repository
        attr_reader :user, :data, :repo

        def initialize(user, data)
          @user = user
          @data = data
        end

        def run
          @repo = find || create
          update
          permit unless permitted?
          repo
        end

        private

          def find
            ::Repository.where(:owner_name => owner_name, :name => name).first
          end

          def create
            ::Repository.create!(:owner_name => owner_name, :name => name)
          end
          # instrument :create, :level => :debug

          def permitted?
            user.repositories.include?(repo)
          end

          def permit
            user.permissions.create!(
              :user => user,
              :repository => repo,
              :admin => data['permissions']['admin']
            )
          end
          # instrument :permit, :level => :debug

          def update
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
