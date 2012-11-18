module Travis
  module Services
    class FindDailyReposStats < Base
      def run
        select scope(:repository).
          select(['date(created_at) AS date', 'count(created_at) AS count']).
          where('last_build_id IS NOT NULL').
          group('date').
          order('date').to_sql
      end

      private

        def select(sql)
          ActiveRecord::Base.connection.select_all(sql)
        end
    end
  end
end
