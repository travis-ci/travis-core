require 'travis/model/build/config/env'
require 'travis/model/build/config/language'
require 'travis/model/build/config/matrix'
require 'travis/model/build/config/obfuscate'

class Build
  class Config
    NORMALIZERS = [Env, Language]

    attr_reader :config, :options

    def initialize(config, options = {})
      @config = (config || {}).deep_symbolize_keys
      @options = options
    end

    def normalize
      NORMALIZERS.inject(config) do |config, normalizer|
        normalizer.new(config, options).run
      end
    end

    def obfuscate
      Obfuscate.new(config, options).run
    end
  end
end
