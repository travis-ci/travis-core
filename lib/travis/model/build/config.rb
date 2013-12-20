# require 'model/build/config/env'
# require 'model/build/config/lang'

class Build
  class Config
    class Env < Struct.new(:config, :options)
      def normalize(config)
        return config unless config[:env]
        result = env_values(config[:env])
        if result[:env]
          config[:env] = result[:env]
        else
          config.delete(:env)
        end
        config[:global_env] = result[:global] if result[:global]
        config
      end

      def env_values(values)
        env = values
        global = nil

        if env.is_a?(Hash) && (env[:global] || env[:matrix])
          global = env[:global]
          env    = env[:matrix]
        end

        if env
          env = [env] unless env.is_a?(Array)
          env = env_hashes(env)
        end

        if global
          global = [global] unless global.is_a?(Array)
          global = env_hashes(global)
        end

        { env: env, global: global }
      end

      def env_hashes(lines)
        process_line = ->(line) do
          if line.is_a?(Hash)
            env_hash_to_string(line)
          elsif line.is_a?(Array)
            line.map { |line| env_hash_to_string(line) }
          else
            line
          end
        end

        if lines.is_a?(Array)
          lines.map { |env| process_line.(env) }
        else
          process_line.(lines)
        end
      end

      def env_hash_to_string(hash)
        return hash unless hash.is_a?(Hash)
        return hash if hash.has_key?(:secure)

        hash.map { |k,v| "#{k}=#{v}" }.join(' ')
      end
    end

    class Env1 < Struct.new(:config, :options)
      def env
        config[:env]
      end

      def normalize(config)
        return config unless config[:env]
        # result = env_values(config[:env])
        # if result[:env]
        #   config[:env] = result[:env]
        # else
        #   config.delete(:env)
        # end
        # config[:global_env] = result[:global] if result[:global]
        config
      end
    end

    NORMALIZERS = [Env]

    attr_reader :config, :options

    def initialize(config, options = {})
      config ||= {}
      @config = config.deep_symbolize_keys
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
