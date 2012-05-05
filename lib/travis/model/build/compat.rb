class Build

  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def status=(result)
      self.result = result
    end
  end
end

