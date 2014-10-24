require 'core_ext/hash/compact'

class Build
  class Config
    class Features < Struct.new(:config, :options)
      def run
        config = self.config
        config = remove_multi_os(config) unless options[:multi_os]
        config
      end

      def remove_multi_os(config)
        config.delete(:os)
        includes = config[:matrix] && config[:matrix][:include]
        return config unless includes.is_a?(Array)
        includes.delete_if { |c| !c.respond_to?(:key) || c.key?(:os) }
        config
      end
    end
  end
end
