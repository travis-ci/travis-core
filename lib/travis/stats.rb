module Travis
  class Stats
    class << self
      def daily_repository_counts
        repositories = Repository.
          select(['date(created_at) AS created_at_date', 'count(created_at) AS repository_count']).
          where('last_build_id IS NOT NULL').
          group('created_at_date').
          order('created_at_date')

        total_repositories = 0

        repositories.map do |repo|
          {
            date: repo.created_at_date,
            added_on_date: repo.repository_count.to_i,
            total_growth: total_repositories += repo.repository_count.to_i
          }
        end
      end

      def daily_tests_counts
        tests = Job.
          select(['date(created_at) AS created_at_date', 'count(created_at) AS config']).
          group('created_at_date').
          order('created_at_date').
          where(['created_at > ?', 28.days.ago]).
          where(['type = ?', 'Job::Test'])

        tests.map do |job|
          {
            date: job.created_at_date,
            run_on_date: job.config.to_i
          }
        end
      end
    end
  end
end
