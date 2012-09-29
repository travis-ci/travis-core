module Travis
  module Services
    module Stats
      class DailyTests < Base
        def run
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
end
