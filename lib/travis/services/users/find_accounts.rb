module Travis
  module Services
    module Users
      class FindAccounts < Base
        def run
          ([current_user] + orgs).map do |record|
            ::Account.from(record, :repos_count => repos_counts[record.login])
          end
        end

        private

          def orgs
            Organization.where(:login => account_names)
          end

          def repos_counts
            @repos_counts ||= Repository.counts_by_owner_names(account_names)
          end

          def account_names
            current_user.repositories.administratable.select(:owner_name).map(&:owner_name).uniq
          end
      end
    end
  end
end
