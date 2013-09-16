require 'hashr'

class Build
  class ResultMessage
    SHORT = {
      pending:  'Pending',
      passed:   'Passed',
      failed:   'Failed',
      broken:   'Broken',
      fixed:    'Fixed',
      failing:  'Still Failing',
      errored:  'Errored',
      canceled: 'Canceled'
    }

    FULL = {
      pending:  'Build #%d is pending.',
      passed:   'Build #%d passed.',
      failed:   'Build #%d failed.',
      broken:   'Build #%d was broken.',
      fixed:    'Build #%d was fixed.',
      failing:  'Build #%d is still failing.',
      errored:  'Build #%d has errored.',
      canceled: 'Build #%d was canceled.'
    }

    attr_reader :build

    def initialize(build)
      build = Hashr.new(build) if build.is_a?(Hash)
      @build = build
    end

    def short
      SHORT[result_key]
    end

    def full
      FULL[result_key] % build.number
    end

    private

      def result_key
        current  = build.state.try(:to_sym)
        previous = build.previous_state.try(:to_sym)

        if [:created, :started, :queued].include?(current)
          :pending
        elsif previous == :passed && current == :failed
          :broken
        elsif previous == :failed && current == :passed
          :fixed
        elsif previous == :failed && current == :failed
          :failing
        else
          current
        end
      end
  end
end
