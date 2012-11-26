require 'hashr'

class Build
  class ResultMessage

    # TODO extract to I18n
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
      pending:  'The build is pending.',
      passed:   'The build passed.',
      failed:   'The build failed.',
      broken:   'The build was broken.',
      fixed:    'The build was fixed.',
      failing:  'The build is still failing.',
      errored:  'The build has errored.',
      canceled: 'The build was canceled.'
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
      FULL[result_key]
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
