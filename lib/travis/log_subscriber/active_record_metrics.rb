require 'active_support/log_subscriber'

module Travis
  module LogSubscriber
    class ActiveRecordMetrics < ActiveSupport::LogSubscriber
      def self.attach
        attach_to(:active_record)
      end

      def sql(event)
        return if 'SCHEMA' == event.payload[:name]
        name, sql, duration = event.payload[:name], event.payload[:sql].downcase, event.duration
        if name.is_a?(Array)
          name = "generic"
        end

        metric_name =
          if name.present?
            Metriks.timer("active_record.reads").update(duration)
            "active_record.#{name.downcase.gsub(/ /, ".")}"
          elsif %w{insert delete update}.include?(sql[0..6])
            Metriks.timer("active_record.writes").update(duration)
            # Metriks.timer("active_record.log_updates").update(duration) if log_update?(sql)
            "active_record.#{sql[0..6]}"
          end

        Metriks.timer(metric_name).update(duration)
      end

      private

        def log_update?(sql)
          sql.include?('artifacts') && sql.include?("content = coalesce(content, '')")
        end
    end
  end
end
