require 'travis/model/build/config/env'
require 'travis/model/build/config/obfuscate'

class Build
  class Config
    NORMALIZERS = [Env]

    attr_reader :config, :options

    def initialize(config, options = {})
      @config = (config || {}).deep_symbolize_keys
      @options = options
    end

    def normalize
      normalizers.inject(config) do |config, normalizer|
        normalizer.run(config)
      end
    end

    def obfuscate
      Obfuscate.new(options).run(config.dup)
    end

    private

      def normalizers
        NORMALIZERS.map { |const| const.new(options) }
      end
  end
end
