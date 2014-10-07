require 'yaml'
require 'json'
require 'openssl'

module Travis
  class Config < Hashr
    class Files
      def load
        filenames.inject({}) do |conf, filename|
          conf.deep_merge(load_file(filename)[Travis.env] || {})
        end
      end

      private

        def load_file(filename)
          YAML.load_file(filename) || {} rescue {}
        end

        def filenames
          @filenames ||= Dir['config/{travis.yml,travis/*.yml}'].sort
        end
    end
  end
end
