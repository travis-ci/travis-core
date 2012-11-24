class Build

  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    extend ActiveSupport::Concern

    module ClassMethods
      def last_result_on(branches, options = {})
        puts '[DEPRECATED] Build.last_result_on is deprecated. Please use Build.last_state_on', caller
        last_state_on(branches, options)
      end
    end

    def matrix_result
      puts '[DEPRECATED] Build#matrix_result is deprecated. Please use Build#matrix_state', caller
      matrix_state
    end

    # used in http api v1, deprecate as soon as v1 gets retired
    def result
      state.try(:to_sym) == :passed ? 0 : 1
    end
  end
end

