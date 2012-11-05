require 'travis/sidekiq/synchronize_user'

module Travis
  module Services
    module Users
      class Sync < Base
        def run
          return if current_user.syncing?
          trigger_sync
        end

        def trigger_sync
          if Travis::Features.user_active?(:sync_via_sidekiq, user) or Travis::Features.enabled_for_all?(:sync_via_sidekiq)
            Travis::Sidekiq::SynchronizeUser.perform_async(user.id)
          else
            publisher.publish({ :user_id => user.id }, :type => 'sync')
          end
          user.update_column(:is_syncing, true)
          true
        end

        def user
          current_user
        end

        private

          def publisher
            Travis::Amqp::Publisher.new('sync.user')
          end
      end
    end
  end
end
