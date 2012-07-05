class Build
  module Matrix
    class Config
      attr_reader :build

      def initialize(build)
        @build = build
      end

      def config
        @config ||= begin
          config = build.config || {}
          keys   = Build::ENV_KEYS & config.keys.map(&:to_sym)
          size   = config.slice(*keys).values.select { |value| value.is_a?(Array) }.max { |lft, rgt| lft.size <=> rgt.size }.try(:size) || 1

          keys.inject([]) do |result, key|
            values = config[key]
            values = [values] unless values.is_a?(Array)
            values = process_env(values) if key == :env

            if values
              values += [values.last] * (size - values.size) if values.size < size
              result << values.map { |value| [key, value] }
            end

            result
          end
        end
      end

      def to_a
        config.to_a
      end
      alias to_ary to_a

      # TODO: I'm lazy and I don't want to change tests for now,
      #       it can be removed later, especially when some tests
      #       that actually test Matrix::Config stop using Build
      def ==(other)
        to_a == other
      end

      def process_env(values)
        values = if build.pull_request?
          remove_encrypted_env_vars(values)
        else
          decrypt_env(values)
        end
      end

      def remove_encrypted_env_vars(values)
        values.map do |value|
          value = [value] unless value.is_a? Array
          result = value.reject do |var|
            var.is_a?(Hash) && var.has_key?(:secure)
          end
          result.length <= 1 ? result.first : result
        end.compact.presence
      end

      def decrypt_env(values)
        values.collect do |value|
          value = [value] unless value.is_a? Array
          result = value.map do |var|
            decrypt(var) do |env|
              env.insert(0, 'SECURE ') unless env.include?('SECURE ')
            end
          end
          result.length == 1 ? result.first : result
        end
      end

      def decrypt(v, &block)
        build.repository.key.secure.decrypt(v, &block)
      end

      def expand
        # recursively builds up permutations of values in the rows of a nested array
        matrix = lambda do |*args|
          base, result = args.shift, args.shift || []
          base = base.dup
          base.empty? ? [result] : base.shift.map { |value| matrix.call(base, result + [value]) }.flatten(1)
        end
        expanded = matrix.call(config).uniq
        include_matrix_configs(exclude_matrix_configs(expanded))
      end

      def exclude_matrix_configs(matrix)
        matrix.reject { |config| exclude_config?(config) }
      end

      def exclude_config?(config)
        # gotta make the first key a string for 1.8 :/
        exclude_configs = matrix_settings[:exclude] || []
        exclude_configs = exclude_configs.map(&:stringify_keys).map(&:to_a).map(&:sort)
        config = config.map { |config| [config[0].to_s, *config[1..-1]] }.sort
        exclude_configs.to_a.any? { |excluded| excluded == config }
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
        exclude_configs = exclude_configs.map(&:stringify_keys).map(&:to_a).map(&:sort)
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
