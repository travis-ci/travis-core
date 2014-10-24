class Build
  class Config
    class OS
      OS_LANGUAGE_MAP = {
        "objective-c" => "osx",
      }
      DEFAULT_OS = "linux"

      attr_reader :config, :options

      def initialize(config, options)
        @config = config
        @options = options
      end

      def run
        os_given? ? config : config.merge(os: os_for_language)
      end

      private

        def os_given?
          config.key?(:os) || config.key?('os')
        end

        def includes
          config.fetch(:matrix, {}).fetch(:include, [])
        end

        def os_for_language
          OS_LANGUAGE_MAP.fetch(config[:language], DEFAULT_OS)
        end
    end
  end
end
