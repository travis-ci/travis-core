module Travis
  module Services
    module Github
      class SyncUser
        class Repository
          class << self
            def unpermit_all(user, repositories)
              user.permissions.where(:repository_id => repositories.map(&:id)).delete_all unless repositories.empty?
            end
          end

          attr_reader :user, :data, :repo

          def initialize(user, data)
            @user = user
            @data = data
          end

          def run
            @repo = find || create
            update
            if permission
              sync_permissions
            elsif permit?
              permit
            end
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

            def permission
              @permission ||= user.permissions.where(:repository_id => repo.id).first
            end

            def sync_permissions
              if permit?
                permission.update_attributes!(permission_data)
              else
                permission.destroy
              end
            end

            def permit?
              push_access? || admin_access? || repo.private?
            end

            def permit
              user.permissions.create!({
                :user  => user,
                :repository => repo
              }.merge(permission_data))
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

            def permission_data
              data['permissions']
            end

            def push_access?
              permission_data['push']
            end

            def admin_access?
              permission_data['admin']
            end
        end
      end
    end
  end
end
