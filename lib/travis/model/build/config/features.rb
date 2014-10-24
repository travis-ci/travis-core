require 'core_ext/hash/compact'

class Build
  class Config
    class Features < Struct.new(:config, :options)
      def run
        config = self.config
        config = remove_multi_os(config) if remove_multi_os?
        config
      end

      def remove_multi_os(config)
        if includes = config[:matrix][:include] and includes.is_a?(Array)
          config[:matrix][:include].delete_if do |config|
            !config.respond_to?(:key) || config.key?(:os)
          end
        end
        config
      end

      def remove_multi_os?
        !options[:multi_os] && config[:matrix] && !config[:matrix].empty?
      end
    end
  end
end

