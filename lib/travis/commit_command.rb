module Travis
  class CommitCommand
    attr_reader :message

    def initialize(message)
      @message = message.to_s
    end

    def skip?
      command == 'skip'
    end

    private

    def command
      message =~ /\[ci(?: |:)([\w ]*)\]/i && $1.downcase
    end
  end
end
