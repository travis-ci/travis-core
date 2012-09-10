class Artifact::Log < Artifact
  class << self
    # use job_id to avoid loading a log artifact into memory
    def append(id, chars)
      meter do
        update_all(["content = COALESCE(content, '') || ?", filter(chars)], ["job_id = ?", id])
      end
    end

    private

      def filter(chars)
        # postgres seems to have issues with null chars
        chars.gsub("\0", '')
      end

      # TODO should be done by Travis::LogSubscriber::ActiveRecordMetrics but i can't get it
      # to be picked up outside of rails
      def meter
        started = Time.now
        yield
        duration = Time.now - started
        Metriks.timer('active_record.log_updates').update(Time.now - started)
      end
  end

  # def append_message(severity, message)
  #   self.class.append(id, "\\n\\n#{colorize(severity == :warn ? :yellow : :green, message)}")
  # end
end

