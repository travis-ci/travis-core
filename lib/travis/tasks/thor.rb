require 'bundler/setup'
require 'travis'

$stdout.sync = true

module Travis
  module Tasks
    class Thor < ::Thor
      namespace 'travis:hub'

      desc 'start', 'Consume AMQP messages from the worker'
      method_option :env, :aliases => '-e', :default => 'development'
      def start
        Travis::Hub.start(:env => options['env'])
      end
    end
  end
end

