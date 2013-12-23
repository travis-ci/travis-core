require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/array/wrap'

class Build
  module Matrix
    class Config
      DEFAULT_LANG = 'ruby'

      EXPANSION_KEYS_FEATURE = [:os]

      EXPANSION_KEYS_LANGUAGE = {
        'c'           => [:compiler],
        'clojure'     => [:lein, :jdk],
        'cpp'         => [:compiler],
        'erlang'      => [:otp_release],
        'go'          => [:go],
        'groovy'      => [:jdk],
        'haskell'     => [:ghc],
        'java'        => [:jdk],
        'node_js'     => [:node_js],
        'objective-c' => [:rvm, :gemfile, :xcode_sdk, :xcode_scheme],
        'perl'        => [:perl],
        'php'         => [:php],
        'python'      => [:python],
        'ruby'        => [:rvm, :gemfile, :jdk],
        'scala'       => [:scala, :jdk]
      }

      EXPANSION_KEYS_UNIVERSAL = [:env, :branch]

      class << self
        def matrix_keys(config, options = {})
          lang = Array(config.symbolize_keys[:language]).first
          keys = ENV_KEYS
          keys &= EXPANSION_KEYS_LANGUAGE.fetch(lang, EXPANSION_KEYS_LANGUAGE[DEFAULT_LANG])
          keys << :os if options[:multi_os]
          keys | EXPANSION_KEYS_UNIVERSAL
        end
      end

      attr_reader :config, :options

      def initialize(config, options = {})
        @config = config ? config.dup : {}
        @options = options
      end

      def matrix_settings
        config[:matrix] || {}
      end

      def expand
        configs = expand_matrix
        configs = include_matrix_configs(exclude_matrix_configs(configs))
        configs.map { |config| merge_config(Hash[config]) }
      end

      private

        def expand_matrix
          rows = config.slice(*expand_keys).values.select { |value| value.is_a?(Array) }
          max_size = rows.max_by(&:size).try(:size) || 1

          array = expand_keys.inject([]) do |result, key|
            values = Array.wrap(config[key])
            values += [values.last] * (max_size - values.size)
            result << values.map { |value| [key, value] }
          end

          permutations(array).uniq
        end

        # recursively builds up permutations of values in the rows of a nested array
        def permutations(base, result = [])
          base = base.dup
          base.empty? ? [result] : base.shift.map { |value| permutations(base, result + [value]) }.flatten(1)
        end

        def merge_config(row)
          config.select { |key, value| include_key?(key) }.merge(row)
        end

        def expand_keys
          @expand_keys ||= config.keys.map(&:to_sym) & self.class.matrix_keys(config, multi_os: options[:multi_os])
        end

        def exclude_matrix_configs(configs)
          configs.reject { |config| exclude_config?(config) }
        end

        def exclude_config?(config)
          exclude_configs = matrix_settings[:exclude] || []
          exclude_configs = exclude_configs.compact.map(&:stringify_keys).map(&:to_a).map(&:sort)
          config = config.map { |config| [config[0].to_s, *config[1..-1]] }.sort
          exclude_configs.any? { |excluded| excluded == config }
        end

        def include_matrix_configs(configs)
          include_configs = matrix_settings[:include] || []
          include_configs = include_configs.map(&:to_a).map(&:sort)
          configs + include_configs
        end

        def include_key?(key)
          self.class.matrix_keys(config, options).include?(key) || !known_env_key?(key)
        end

        def known_env_key?(key)
          (Build::ENV_KEYS | EXPANSION_KEYS_FEATURE).include?(key)
        end

        def language
          @language ||= Array(config.symbolize_keys[:language]).first || DEFAULT_LANG
        end
    end
  end
end
