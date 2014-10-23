module Support
  module Log
    def capture_log
      io = StringIO.new
      with_logger(Logger.new(io)) { yield }
      io.string
    end

    def with_logger(*args)
      logger, level = Travis.logger, level
      Travis.logger = args.shift
      Travis.logger.level = args.shift || Logger::INFO
      result = yield
      Travis.logger, Travis.logger.level = logger, level
      result
    end

    def capture_stdout
      out = StringIO.new
      $stdout = out
      yield
      return out.string
    ensure
      $stdout = STDOUT
    end
  end
end
