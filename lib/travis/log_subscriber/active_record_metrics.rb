module Travis
  module LogSubscriber
    class ActiveRecordMetrics < ActiveSupport::LogSubscriber
      def sql(event)
        return if 'SCHEMA' == event[:name]
        name, sql, duration = event[:name], event[:sql], event.duration

        metric_name =
          if name.present?
            Metriks.timer("active_record.reads").update(duration)
            "active_record.#{name.downcase.gsub(/ /, ".")}"
          elsif %w{insert delete update}.include?(sql[0..6].downcase)
            Metriks.timer("active_record.writes").update(duration)
            "active_record.#{sql[0..6].downcase}"
          end

        Metriks.timer(metric_name).update(duration)
      end

      def self.attach
        attach_to(:active_record)
      end
    end
  end
end
