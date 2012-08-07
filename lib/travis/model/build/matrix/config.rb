class Build
  module Matrix
    class Config
      attr_reader :build, :config

      def initialize(build)
        @build  = build
        @config = build.config || {}
      end

      def keys
        @keys ||= Build::ENV_KEYS & config.keys.map(&:to_sym)
      end

      def size
        @size ||= config.slice(*keys).values.select { |value| value.is_a?(Array) }.max { |lft, rgt| lft.size <=> rgt.size }.try(:size) || 1
      end

      def to_a
        @as_array ||= begin
          keys.inject([]) do |result, key|
            values = normalize_config_values(key, config[key])
            values = [values] unless values.is_a?(Array)

            if values
              values += [values.last] * (size - values.size) if values.size < size
              result << values.map { |value| [key, value] }
            end

            result
          end
        end
      end
      alias to_ary to_a

      def normalize_config_values(key, values)
        method_name = "normalize_#{key}_values"
        values = send(method_name, values) if respond_to?(method_name)
        values
      end

      def normalize_env_values(values)
        global = nil

        if values.is_a?(Hash) && (values[:global] || values[:matrix])
          global = values[:global]
          values = values[:matrix]
        end

        if global
          global = [global] unless global.is_a?(Array)
        else
          return values
        end

        values = [values] unless values.is_a?(Array)
        values.map do |line|
          line = [line] unless line.is_a?(Array)
          line + global
        end
      end

      # TODO: I'm lazy and I don't want to change tests for now,
      #       it can be removed later, especially when some tests
      #       that actually test Matrix::Config stop using Build
      def ==(other)
        to_a == other
      end

      def expand
        # recursively builds up permutations of values in the rows of a nested array
        matrix = lambda do |*args|
          base, result = args.shift, args.shift || []
          base = base.dup
          base.empty? ? [result] : base.shift.map { |value| matrix.call(base, result + [value]) }.flatten(1)
        end
        expanded = matrix.call(to_a).uniq
        include_matrix_configs(exclude_matrix_configs(expanded))
      end

      def exclude_matrix_configs(matrix)
        matrix.reject { |config| exclude_config?(config) }
      end

      def matrix_settings
        config[:matrix] || {}
      end

      def exclude_matrix_configs(matrix)
        matrix.reject { |config| exclude_config?(config) }
      end

      def exclude_config?(config)
        # gotta make the first key a string for 1.8 :/
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
    end
  end
end
