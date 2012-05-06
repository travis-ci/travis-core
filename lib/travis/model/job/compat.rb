class Job
  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def status=(result)
      puts '[DEPRECATED] setting Job#status is deprecated. Please use Job#result='
      self.result = result
    end
  end
end

