module Travis
  module Services
    class Stats < Base
      def daily_repository_counts
        total_repos = 0
        repositories.map do |repo|
          {
            :date => repo.created_at,
            :added_on_date => repo.repos_count.to_i,
            :total_growth => total_repos += repo.repos_count.to_i
          }
        end
      end

      def daily_tests_counts
        tests.map do |job|
          {
            :date => job.created_at,
            :run_on_date => job.config.to_i
          }
        end
      end

      private

        def repositories
          scope(:repository).
            select(['date(created_at) AS created_at', 'count(created_at) AS repos_count']).
            where('last_build_id IS NOT NULL').
            group('created_at').
            order('created_at')
        end

        def tests
          scope(:job).
            select(['date(created_at) AS created_at', 'count(created_at) AS config']).
            group('created_at').
            order('created_at').
            where(['created_at > ?', 28.days.ago]).
            where(['type = ?', 'Job::Test'])
        end
    end
  end
end
