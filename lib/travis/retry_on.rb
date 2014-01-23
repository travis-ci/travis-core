module Travis
  module RetryOn
    def retry_on(*errors)
      options = errors.last.is_a?(Hash) ? errors.pop : {}
      tries = 0
      max_tries = options[:max_tries] || 3
      begin
        yield
      rescue *errors
        tries += 1
        if options[:sleep]
          sleep options[:sleep]
        end
        tries < max_tries ? retry : raise
      end
    end
  end
end
