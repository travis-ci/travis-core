class Build
  class Config
    class Dist
      DIST_LANGUAGE_MAP = {
        'objective-c' => 'osx'
      }.freeze
      DIST_OS_MAP = {
        'osx' => 'osx'
      }.freeze
      DIST_SERVICES_MAP = {
        'docker' => 'trusty'
      }.freeze
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
        (Array(config[:services]) || []).each do |service|
          return DIST_SERVICES_MAP[service] if DIST_SERVICES_MAP.key?(service)
        end
        return DEFAULT_DIST if options[:multi_os]
        DIST_OS_MAP.fetch(Array(config[:os]).first, DEFAULT_DIST)
      end
    end
  end
end
