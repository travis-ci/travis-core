require 'core_ext/hash/deep_symbolize_keys'

module Travis
  module Services
    class UpdateWorkers < Base
      register :update_workers

      def run
        reports.each do |report|
          record = record_for(report)
          record ? update(record, report) : create(report)
        end
      end

      private

        def reports
          @reports ||= params[:reports].map(&:deep_symbolize_keys)
        end

        def create(report)
          Worker.create(report)
        end

        def update(record, report)
          change?(record, report) ? change(record, report) : record.touch
        end

        def change(record, report)
          report = normalize(report)
          record.update_attributes(report)
        end

        def change?(record, report)
          job_changed?(record, report) || state_changed?(record, report)
        end

        def record_for(report)
          records.detect { |record| record.full_name == full_name(report) }
        end

        def records
          @records ||= ::Worker.all
        end

        def full_names
          @full_names ||= reports.map { |report| full_name(report) }
        end

        def full_name(report)
          report[:full_name] || report.values_at(:host, :name).join(':')
        end

        def state_changed?(record, report)
          record.state.to_s != report[:state].to_s
        end

        def job_changed?(record, report)
          if payloads?(record, report)
            record.job[:id] != report[:payload][:job][:id]
          else
            false
          end
        end

        def normalize(report)
          return unless payload = report[:payload]
          job  = payload[:job] || {}
          repo = payload[:repo] || payload[:repository] || {}
          report[:payload] = { job: { id: job[:id] }, repo: { id: repo[:slug], id: repo[:slug] } }
          report
        end

        def payloads?(record, report)
          !(record.payload.nil? || report[:payload].nil?)
        end
    end
  end
end
