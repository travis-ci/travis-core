module Travis
  module Services
    module Users
      class Sync < Base
        def run
          return if current_user.syncing?
          publisher.publish({ :user_id => current_user.id }, :type => 'sync')
          current_user.update_column(:is_syncing, true)
          true
        end

        private

          def publisher
            Travis::Amqp::Publisher.new('sync.user')
          end
      end
    end
  end
end
