class Job
  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def status=(result)
      puts '[DEPRECATED] setting Job#status is deprecated. Please use Job#result=', caller
      self.result = result
    end

    # used in http api v1, deprecate as soon as v1 gets retired
    def result
      state.try(:to_sym) == :passed ? 0 : 1
    end

    # currently sent by the worker
    def result=(result)
      Travis.logger.warn("[DEPRECATED] setting result #{result.inspect} to #{inspect}. Set :state instead.")
      self.state = map_legacy_result(result) || result
    end

    # TODO remove once we've populated the state column
    def state
      state = read_attribute(:state)
      state = read_attribute(:result) == 0 ? 'passed' : 'failed' if state == 'finished'
      state
    end
  end
end

