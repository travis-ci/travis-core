require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/array/wrap'

class Build
  class Config
    class Matrix
      attr_reader :config, :options

      def initialize(config, options = {})
        @config = config || {}
        @options = options
      end

      def matrix_settings
        config[:matrix] || {}
      end

      def expand
        configs = expand_matrix
        configs = include_matrix_configs(exclude_matrix_configs(configs))
        configs.map { |row| config.merge(Hash[row]) }
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

        def expand_keys
          @expand_keys ||= config.keys.map(&:to_sym) & Build.matrix_keys_for(config, options)
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
    end
  end
end
