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
      alias to_ary to_a

      # TODO: I'm lazy and I don't want to change tests for now,
      #       it can be removed later, especially when some tests
      #       that actually test Matrix::Config stop using Build
      def ==(other)
        to_a == other
      end

      def process_env(env_groups)
        env_groups.map do |env_group|
          env_group = [env_group] unless env_group.is_a? Array

          result = if build.pull_request?
            remove_encrypted_env_vars(env_group)
          else
            decrypt_env(env_group)
          end

          # For backwards compatibility, if you start with one env var
          # instead of array, return one item or nil, I think we can get
          # rid of this later and always treat env values as arrays
          result.length <= 1 ? result.first : result
        end.compact.presence
      end

      def remove_encrypted_env_vars(env)
        env.reject do |var|
          var.is_a?(Hash) && var.has_key?(:secure)
        end
      end

      def decrypt_env(env)
        env.map do |var|
          decrypt(var) do |var|
            var.insert(0, 'SECURE ') unless var.include?('SECURE ')
          end
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
        expanded = matrix.call(to_a).uniq
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
