class Repository
  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def self.included(base)
      base.before_save :copy_last_build_status_to_last_build_result
    end

    def copy_last_build_status_to_last_build_result
      self.last_build_result = self.last_build_status
    end
  end
end

