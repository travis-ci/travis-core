require 'travis/cli/config'
require 'travis/cli/deploy'

module Travis
  module Cli
    autoload :Config, 'travis/cli/config'
    autoload :Deploy, 'travis/cli/deploy'

    protected

      def run(cmd, options = {})
        with_clean_env do
          cmd = cmd.strip
          puts "$ #{options[:echo] || cmd}" unless options[:echo].is_a?(FalseClass)
          system cmd
        end
      end

      def say(message)
        shell.say(message, :green)
      end

      def error(message)
        message = shell.set_color(message, :red)
        shell.error(message)
        exit 1
      end

      def with_clean_env
        Bundler.with_clean_env do
          ENV['RUBYOPT'] = nil
          yield
        end
      end
  end
end
