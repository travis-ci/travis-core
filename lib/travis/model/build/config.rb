require 'travis/model/build/config/env'

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
        normalizer.normalize(config)
      end
    end

    def normalizers
      NORMALIZERS.map { |const| const.new(config, options) }
    end
  end
end
