class Build

  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def self.included(base)
      base.before_save :copy_status_to_result
    end

    def copy_status_to_result
      self.result = self.status
    end
  end
end

