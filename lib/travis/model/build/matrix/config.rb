require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/array/wrap'

class Build
  module Matrix
    class Config
      attr_reader :build, :config

      DEFAULT_LANG = 'ruby'

      def initialize(build)
        @build  = build
        @config = build.config ? build.config.dup : {}
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
          config = build.config.merge(row)
          config.delete_if { |key, value| !lang_expands_key?(key) }
        end

        def multi_os_enabled?
          Travis::Features.enabled_for_all?(:multi_os) || Travis::Features.active?(:multi_os, build.repository)
        end

        def expand_keys
          @expand_keys ||= begin
            keys = Build::ENV_KEYS & config.keys.map(&:to_sym) & Build.matrix_lang_keys(config)
            keys << :os if multi_os_enabled?
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

        def lang_expands_key?(key)
          (expand_keys | language_expansion_keys).include?(key) ||
          !(Build::ENV_KEYS | Build::EXPANSION_KEYS_FEATURE).include?(key)
        end

        def language_expansion_keys
          Build::EXPANSION_KEYS_LANGUAGE.fetch(language, Build::EXPANSION_KEYS_LANGUAGE[DEFAULT_LANG])
        end

        def language
          @language ||= Array(config.symbolize_keys[:language]).first || DEFAULT_LANG
        end
    end
  end
end
