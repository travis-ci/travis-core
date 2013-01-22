require 'core_ext/hash/deep_symbolize_keys'

module Travis
  module Services
    class UpdateWorkers < Base
      register :update_workers

      def run
        reports.each do |report|
          report = normalize(report)
          worker = worker_for(report)
          worker ? update(worker, report) : create(report)
        end
      end

      private

        def reports
          @reports ||= params[:reports].map(&:deep_symbolize_keys)
        end

        def create(report)
          Worker.create(report)
        end

        def update(worker, report)
          changed?(worker, report) ? worker.update_attributes(report) : worker.touch
        end

        def worker_for(report)
          workers.detect { |worker| worker.full_name == full_name(report) }
        end

        def workers
          @workers ||= ::Worker.all
        end

        def full_names
          @full_names ||= reports.map { |report| full_name(report) }
        end

        def full_name(report)
          report[:full_name] || report.values_at(:host, :name).join(':')
        end

        def changed?(worker, report)
          job_changed?(worker, report) || state_changed?(worker, report)
        end

        def state_changed?(worker, report)
          worker.state.to_s != report[:state].to_s
        end

        def job_changed?(worker, report)
          if payloads?(worker, report)
            worker.job[:id] != report.fetch(:payload, {}).fetch(:job, {})[:id]
          else
            false
          end
        end

        def normalize(report)
          return report unless payload = report[:payload]
          job  = payload[:job] || {}
          repo = payload[:repo] || payload[:repository] || {}
          report.merge(payload: { job: { id: job[:id] }, repo: { id: repo[:id], slug: repo[:slug] } })
        end

        def payloads?(worker, report)
          !(worker.payload.nil? || report[:payload].nil?)
        end
    end
  end
end
