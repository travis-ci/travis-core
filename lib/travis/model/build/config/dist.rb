class Build
  class Config
    class Dist
      DIST_LANGUAGE_MAP = {
        'objective-c' => 'osx',
      }
      DIST_OS_MAP = {
        'osx' => 'osx'
      }
      DEFAULT_DIST = 'precise'

      attr_reader :config, :options

      def initialize(config, options)
        @config = config
        @options = options
      end

      def run
        return config if config.key?(:dist) || config.key?('dist')
        config.merge(dist: dist_for_language)
      end

      private

      def dist_for_language
        return DIST_LANGUAGE_MAP[config[:language]] if
          DIST_LANGUAGE_MAP.key?(config[:language])
        return DEFAULT_DIST if options[:multi_os]
        return DIST_OS_MAP.fetch(Array(config[:os]).first, DEFAULT_DIST)
      end
    end
  end
end
