class Worker
  class Status
    class Worker
      attr_reader :report, :record

      def initialize(report, record)
        @report = report
        @record = record
      end

      def exists?
        !!record
      end

      def create
        @record = ::Worker.create!(report)
      end

      def update
        unless record.state.to_s == state
          record.update_attributes!(report)
          record.notify(:update)
        end
      end

      private

        def state
          report['state'].to_s
        end

        def full_name
          @full_name ||= report.values_at(*%w(host name)).join(':')
        end
    end

    class << self
      def update(reports)
        new(reports).run
      end
    end

    attr_reader :reports

    def initialize(reports)
      @reports = reports
    end

    def run
      create
      touch
      update
    end

    private

      def create
        workers.each { |worker| worker.create unless worker.exists? }
      end

      def touch
        scope.update_all(:last_seen_at => Time.now.utc)
      end

      def update
        workers.each { |worker| worker.update }
      end

      def workers
        @workers ||= reports.map { |report| Worker.new(report, scope.detect { |record| record.full_name == full_name(report) }) }
      end

      def scope
        @scope ||= ::Worker.where("(host || ':' || name) IN (?)", full_names)
      end

      def full_names
        @full_names ||= reports.map { |report| full_name(report) }
      end

      def full_name(report)
        report.values_at(*%w(host name)).join(':')
      end
  end
end
