require 'core_ext/module/include'
require 'core_ext/module/prepend_to'

module Travis
  module Exceptions
    module Handling
      def rescues(name, options = {})
        prepend_to(name) do |object, method, *args, &block|
          begin
            method.call(*args, &block)
          rescue options[:from] || Exception => e
            Exceptions.handle(e)
          end
        end
      end
    end
  end
end
