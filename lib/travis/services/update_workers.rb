module Travis
  module Services
    class UpdateWorkers < Base
      register :update_workers

      def run
        reports.each do |report|
          record = record_for(report)
          record ? update(record, report) : create(report)
        end
        touch_all
      end

      private

        def reports
          @reports ||= params[:reports].map(&:symbolize_keys)
        end

        def create(report)
          Worker.create!(report)
        end

        def update(record, report)
          return unless change?(record, report)
          report.delete('config')
          record.update_attributes!(report)
          record.notify(:update)
        end

        def change?(record, report)
          record.state.to_s != report[:state].to_s
        end

        def touch_all
          records.update_all(:last_seen_at => Time.now.utc)
        end

        def record_for(report)
          records.detect { |record| record.full_name == full_name(report) }
        end

        def records
          @records ||= ::Worker.where("full_name IN (?)", full_names)
        end

        def full_names
          @full_names ||= reports.map { |report| full_name(report) }
        end

        def full_name(report)
          report.values_at(:host, :name).join(':')
        end
    end
  end
end
