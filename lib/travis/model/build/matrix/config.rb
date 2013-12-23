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

      def self.matrix_lang_keys(config, options = {})
        keys = ENV_KEYS
        lang = Array(config.symbolize_keys[:language]).first
        keys &= EXPANSION_KEYS_LANGUAGE.fetch(lang, EXPANSION_KEYS_LANGUAGE[DEFAULT_LANG])
        keys << :os if options[:multi_os]
        keys | EXPANSION_KEYS_UNIVERSAL
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
        # recursively builds up permutations of values in the rows of a nested array
        matrix = lambda do |*args|
          base, result = args.shift, args.shift || []
          base = base.dup
          base.empty? ? [result] : base.shift.map { |value| matrix.call(base, result + [value]) }.flatten(1)
        end

        expanded = matrix.call(to_a).uniq
        expanded = include_matrix_configs(exclude_matrix_configs(expanded))
        expanded.map { |row| expand_row(row) }
      end

      private

        def expand_row(row)
          row = Hash[row] unless row.is_a?(Hash)
          row = config.merge(row)
          row.select { |key, value| include_key?(key) }
        end

        def expand_keys
          @expand_keys ||= begin
            keys = Build::ENV_KEYS & config.keys.map(&:to_sym) & self.class.matrix_lang_keys(config, multi_os: options[:multi_os])
            keys << :os if options[:multi_os]
            keys
          end
        end

        def to_a
          @as_array ||= expand_keys.inject([]) do |result, key|
            values = Array.wrap(config[key])
            values += [values.last] * (size - values.size) if values.size < size
            result << values.map { |value| [key, value] }
          end
        end

        def size
          @size ||= begin
            rows = config.slice(*expand_keys).values.select { |value| value.is_a?(Array) }
            rows.max_by(&:size).try(:size) || 1
          end
        end

        def exclude_matrix_configs(matrix)
          matrix.reject { |config| exclude_config?(config) }
        end

        def exclude_config?(config)
          exclude_configs = matrix_settings[:exclude] || []
          exclude_configs = exclude_configs.compact.map(&:stringify_keys).map(&:to_a).map(&:sort)
          config = config.map { |config| [config[0].to_s, *config[1..-1]] }.sort
          exclude_configs.to_a.any? { |excluded| excluded == config }
        end

        def include_matrix_configs(matrix)
          include_configs = matrix_settings[:include] || []
          include_configs = include_configs.map(&:to_a).map(&:sort)
          matrix + include_configs
        end

        def include_key?(key)
          (expand_keys | language_keys).include?(key) ||
          !(Build::ENV_KEYS | EXPANSION_KEYS_FEATURE).include?(key)
        end

        def language_keys
          EXPANSION_KEYS_LANGUAGE.fetch(language, EXPANSION_KEYS_LANGUAGE[DEFAULT_LANG])
        end

        def language
          @language ||= Array(config.symbolize_keys[:language]).first || DEFAULT_LANG
        end
    end
  end
end
