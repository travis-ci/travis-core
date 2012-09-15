module Travis
  module Services
    class Stats < Base
      def daily_repository_counts
        select scope(:repository).
          select(['date(created_at) AS date', 'count(created_at) AS count']).
          where('last_build_id IS NOT NULL').
          group('created_at').
          order('created_at').to_sql
      end

      def daily_tests_counts
        select scope(:job).
          select(['date(created_at) AS date', 'count(created_at) AS count']).
          group('created_at').
          order('created_at').
          where(['created_at > ?', 28.months.ago]).to_sql
      end

      private

        def select(sql)
          ActiveRecord::Base.connection.select_all(sql)
        end
    end
  end
end
