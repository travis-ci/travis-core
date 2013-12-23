require 'active_support/core_ext/array/wrap'

class Build
  class Config
    class Language < Struct.new(:config, :options)
      def run
        config[:language] = Array.wrap(config[:language]).first || Build::DEFAULT_LANG
        config.select { |key, value| include_key?(key) }
      end

      private

        def include_key?(key)
          matrix_keys.include?(key) || !known_env_key?(key)
        end

        def matrix_keys
          Build.matrix_keys(config, options)
        end

        def known_env_key?(key)
          (Build::ENV_KEYS | Build::EXPANSION_KEYS_FEATURE).include?(key)
        end

    end
  end
end

