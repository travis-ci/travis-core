module Travis
  module Services
    class User < Base
      def find_one
        {
          :user => current_user,
          :accounts => accounts,
          :repository_counts => repository_counts
        }
      end

      private

        def accounts
          [current_user] + Organization.where(:login => account_names)
        end

        def repository_counts
          Repository.counts_by_owner_names(account_names)
        end

        def account_names
          @account_names ||= current_user.repositories.administratable.select(:owner_name).map(&:owner_name).uniq
        end
    end
  end
end

