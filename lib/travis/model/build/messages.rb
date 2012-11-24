class Build
  module Messages
    def result_key(data)
      data     = data.symbolize_keys
      current  = data[:state].try(:to_sym)
      previous = data[:previous_state].try(:to_sym)

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

    # TODO extract to I18n

    RESULT_MESSAGES = {
      pending:  'Pending',
      passed:   'Passed',
      failed:   'Failed',
      broken:   'Broken',
      fixed:    'Fixed',
      failing:  'Still Failing',
      errored:  'Errored',
      canceled: 'Canceled'
    }

    RESULT_MESSAGE_SENTENCES = {
      pending:  'The build is pending.',
      passed:   'The build passed.',
      failed:   'The build failed.',
      broken:   'The build was broken.',
      fixed:    'The build was fixed.',
      failing:  'The build is still failing.',
      errored:  'The build has errored',
      canceled: 'The build was canceled'
    }

    def result_message(data = nil)
      RESULT_MESSAGES[result_key(data || self.attributes)]
    end

    def human_result_message(data = nil)
      RESULT_MESSAGE_SENTENCES[result_key(data || self.attributes)]
    end
  end
end
