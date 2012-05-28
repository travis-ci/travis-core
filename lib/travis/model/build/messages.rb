class Build
  module Messages
    def result_key(state, previous, current)
      if state.to_sym != :finished
        :pending
      elsif previous.nil?
        current == 0 ? :passed : :failed
      elsif previous == 0
        current == 0 ? :passed : :broken
      elsif previous == 1
        current == 0 ? :fixed : :still_failing
      end
    end

    # TODO extract to I18n

    RESULT_MESSAGES = {
      :pending => 'Pending',
      :passed  => 'Passed',
      :failed  => 'Failed',
      :broken  => 'Broken',
      :fixed   => 'Fixed',
      :failing => 'Still Failing'
    }

    RESULT_MESSAGE_SENTENCES = {
      :pending => 'The build is pending.',
      :passed  => 'The build passed.',
      :failed  => 'The build failed.',
      :broken  => 'The build was fixed.',
      :fixed   => 'The build was broken.',
      :failing => 'The build is still failing.'
    }

    def result_message(build)
      key = result_key(state, previous_result, result)
      RESULT_MESSAGES[key]
    end

    def human_result_message(build)
      key = result_key(state, previous_result, result)
      RESULT_MESSAGE_SENTENCES[key]
    end
  end
end
