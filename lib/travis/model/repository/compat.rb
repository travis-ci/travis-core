class Repository
  # Hot compatibility code to ensure we can migrate with minimal downtime
  # Add/remove as needed before/after deploying and running migrations.
  module Compat
    def last_build_result_on(params)
      puts '[DEPRECATED] Repositoriy#last_build_result_on is deprecated. use builds.last_state_on(params) (or add a helper object)', caller
      builds.last_state_on(params)
    end

    def last_build_result
      puts '[DEPRECATED] Repositoriy#last_build_result is deprecated. use last_build_state', caller
      last_build_state.try(:to_sym) == :passed ? 0 : 1
    end

    # TODO remove once we've populated the last_build_state column
    def last_build_state
      super || (read_attribute(:last_build_result) == 0 ? :passed : :failed)
    end
  end
end

