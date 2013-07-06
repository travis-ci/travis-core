require 'stringio'

module Support
  module Silence
    def silence
      out, $stdout = $stdout, StringIO.new
      yield
    ensure
      $stdout = out
    end
  end
end
