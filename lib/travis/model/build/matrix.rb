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

    def matrix_finished?
      if matrix_config.fast_finish?
        matrix.all?(&:waiting_for_result?) || matrix.any?(&:finished_unsuccessfully?)
      else
        matrix.all?(&:waiting_for_result?)
      end
    end

    def matrix_duration
      matrix_finished? ? matrix.inject(0) { |duration, job| duration + job.duration.to_i } : nil
    end

    def matrix_state
      tests = matrix.reject { |test| test.allow_failure? }
      if tests.blank?
        :passed
      elsif tests.any?(&:canceled?)
        :canceled
      elsif tests.any?(&:errored?)
        :errored
      elsif tests.any?(&:failed?)
        :failed
      elsif tests.any?(&:created?)
        :created
      elsif tests.any?(&:queued?)
        :queued
      elsif tests.any?(&:started?)
        :started
      elsif tests.all?(&:passed?)
        :passed
      else
        raise StandardError, "Invalid job state (#{tests.map(&:state)})"
      end
    end

    # expand the matrix (i.e. create test jobs) and update the config for each job
    def expand_matrix
      matrix_config.expand.each_with_index do |row, ix|
        attributes = self.attributes.slice(*Job.column_names - ['status', 'result']).symbolize_keys
        attributes.merge!(
          owner: owner,
          number: "#{number}.#{ix + 1}",
          config: row,
          log: Log.new
        )
        matrix.build(attributes)
      end
      matrix_allow_failures # TODO should be able to join this with the loop above
      matrix
    end

    def expand_matrix!
      expand_matrix
      save!
    end

    # Return only the child builds whose config matches against as passed hash
    # e.g. build.filter_matrix(rvm: '1.8.7', env: 'DB=postgresql')
    def filter_matrix(config)
      config.blank? ? matrix : matrix.select { |job| job.matches_config?(config) }
    end

    private

      def matrix_config
        @matrix_config ||= Config::Matrix.new(config, multi_os: multi_os_enabled?)
      end

      def matrix_allow_failures
        configs = matrix_config.allow_failure_configs
        jobs = configs.map { |config| filter_matrix(config) }.flatten
        jobs.each { |job| job.allow_failure = true }
      end
  end
end
