module Travis
  module Exceptions
    autoload :Handling, 'travis/exceptions/handling'
    autoload :Reporter, 'travis/exceptions/reporter'

    class << self
      def handle(exception)
        Reporter.enqueue(exception)
      end
    end
  end
end
