class Repository
  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def last_build_status=(last_build_result)
      self.last_build_result = last_build_result
    end
  end
end

