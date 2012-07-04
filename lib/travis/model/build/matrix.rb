require 'active_support/concern'
require 'active_support/core_ext/hash/keys'
require 'core_ext/hash/deep_symbolize_keys'

class Build

  # A Build contains a number of Job::Test instances that make up the build
  # matrix.
  #
  # The matrix is defined in the build configuration (`.travis.yml`) and
  # expanded (evaluated and instantiated) when the Build is created.
  #
  # A build matrix has 1 to 3 dimensions and can be defined by specifying
  # multiple values for either of:
  #
  #  * a language/vm variant (e.g. 1.9.2, rbx, jruby for a Ruby build)
  #  * a dependency definition (e.g. a Gemfile for a Ruby build)
  #  * an arbitrary env key that can be used from within the test suite in
  #    order to branch out specific variations of the test run
  module Matrix
    extend ActiveSupport::Concern

    ENV_KEYS = [:rvm, :gemfile, :env, :otp_release, :php, :node_js, :scala, :jdk, :python, :perl]

    module ClassMethods
      def matrix?(config)
        config.values_at(*ENV_KEYS).compact.any? { |value| value.is_a?(Array) && value.size > 1 }
      end

      def matrix_keys_for(config)
        keys = ENV_KEYS + [:branch]
        keys & config.keys.map(&:to_sym)
      end
    end

    # Return only the child builds whose config matches against as passed hash
    # e.g. build.matrix_for(rvm: '1.8.7', env: 'DB=postgresql')
    def matrix_for(config)
      config.blank? ? matrix : matrix.select { |job| job.matrix_config?(config) }
    end

    def matrix_finished?(*)
      matrix.all?(&:finished?)
    end

    def matrix_duration
      matrix_finished? ? matrix.inject(0) { |duration, job| duration + job.duration.to_i } : nil
    end

    def matrix_result(config = {})
      tests = matrix_for(config)
      if tests.blank?
        nil
      elsif tests.all?(&:passed_or_allowed_to_fail?)
        0
      elsif tests.any?(&:failed?)
        1
      else
        nil
      end
    end

    protected

      # expand the matrix (i.e. create test jobs) and update the config for each job
      def expand_matrix
        expand_matrix_config(matrix_config.to_a).each_with_index do |row, ix|
          attributes = self.attributes.slice(*Job.column_names).symbolize_keys
          # TODO remove this once migration to the :result column is done
          attributes.delete(:status)
          attributes.merge!(
            :owner => owner,
            :number => "#{number}.#{ix + 1}",
            :config => config.merge(Hash[*row.flatten]),
            :log => Artifact::Log.new
          )
          matrix.build(attributes)
        end
        matrix_allow_failures # TODO should be able to join this with the loop above
      end

      def matrix_allow_failures
        allow_configs = config_matrix_settings[:allow_failures] || []
        allow_configs.each do |config|
          matrix_for(config).each { |m| m.allow_failure = true }
        end
      end

      def matrix_config
        # TODO: I think that at this point it may be good to extract it to
        #       separate class
        @matrix_config ||= begin
          config = self.config || {}
          keys   = ENV_KEYS & config.keys.map(&:to_sym)
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

      def process_env(values)
        values = if pull_request?
          remove_encrypted_env_vars(values)
        else
          decrypt_env(values)
        end
      end

      def remove_encrypted_env_vars(values)
        values.reject do |value|
          value.is_a?(Hash) && value.has_key?(:secure)
        end.presence
      end

      def decrypt_env(values)
        values.collect do |value|
          repository.key.secure.decrypt(value) do |env|
            env.insert(0, 'SECURE ')
          end
        end
      end

      def expand_matrix_config(config)
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
        exclude_configs = config_matrix_settings[:exclude] || []
        exclude_configs = exclude_configs.map(&:stringify_keys).map(&:to_a).map(&:sort)
        config = config.map { |config| [config[0].to_s, *config[1..-1]] }.sort
        exclude_configs.to_a.any? { |excluded| excluded == config }
      end

      def include_matrix_configs(matrix)
        include_configs = config_matrix_settings[:include] || []
        include_configs = include_configs.map(&:to_a).map(&:sort)
        matrix + include_configs
      end

      def config_matrix_settings
        config = self.config || {}
        config[:matrix] || {}
      end
  end
end
