class Build
  module Messages
    def result_key
      if state != :finished
        :pending
      elsif previous_result.nil?
        result == 0 ? :passed : :failed
      elsif previous_result == 0
        result == 0 ? :passed : :broken
      elsif previous_result == 1
        result == 0 ? :fixed : :still_failing
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

    def result_message
      RESULT_MESSAGES[result_key]
    end

    def human_result_message
      RESULT_MESSAGE_SENTENCES[result_key]
    end
  end
end
