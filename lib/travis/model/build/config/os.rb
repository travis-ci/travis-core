class Build
  class Config
    class OS
      OS_LANGUAGE_MAP = {
        "objective-c" => "osx",
      }
      DEFAULT_OS = "linux"

      def initialize(config, options)
        @config = config
        @options = options
      end

      def run
        return @config if @config.key?(:os)

        @config.merge(os: os_for_language(@config[:language]))
      end

      private

      def os_for_language(language)
        OS_LANGUAGE_MAP.fetch(language, DEFAULT_OS)
      end
    end
  end
end
