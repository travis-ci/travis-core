class Job

  # Encapsulates logic for figuring out which queue a given job needs to go
  # into.
  #
  # Queue names for Job::Test instances are configured in `Travis.config` and
  # are determined based on the repository slug (e.g. 'rails/rails' has its own
  # queue) or the language given in the configuration (`.travis.yml`) and
  # default to 'builds.linux'.
  class Queue
    SUDO_AND_SETUID_EXECUTABLES = %w(
      sudo
      ping
    )

    SUDO_DETECTION_REGEXP = /^[^#]*\b(#{SUDO_AND_SETUID_EXECUTABLES.join('|')})\b/

    CUSTOM_STAGES = %w(
      before_install
      install
      before_script
      script
      before_cache
      after_success
      after_failure
      after_script
    ).map(&:to_sym)

    class << self
      def for(job)
        queues.detect(lambda { default }) { |queue| queue.matches?(job) }
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(queue[:queue], queue.reject { |key, value| key == :queue })
        end
      end

      def default
        @default ||= Queue.new(Travis.config.default_queue, {})
      end

      def sudo_detected?(config)
        config.values_at(*CUSTOM_STAGES).compact.flatten.any? do |s|
          SUDO_DETECTION_REGEXP =~ s.to_s
        end
      end
    end

    attr_reader :name, :attrs

    def initialize(name, attrs)
      @name = name
      @attrs = attrs
    end

    def matches?(job)
      matchers = matchers_for(job)
      @attrs.length > 0 && @attrs.all? { |key, value| matchers[key.to_sym] === value }
    end

    private

    def matchers_for(job)
      {
        :slug => "#{job.repository.try(:owner_name)}/#{job.repository.try(:name)}",
        :owner => job.repository.try(:owner_name),
        :os => job.config[:os],
        :language => Array(job.config[:language]).flatten.compact.first,
        :sudo => job.config.fetch(:sudo) { !repo_is_default_docker?(job) },
        :dist => job.config[:dist],
        :osx_image => job.config[:osx_image],
      }
    end

    def repo_is_default_docker?(job)
      return true if Travis::Github::Education.education_queue?(job.repository.try(:owner))
      return false unless Travis::Features.feature_active?(:docker_default_queue)
      !self.class.sudo_detected?(job.config) && repo_created_after_docker_cutoff?(job.repository)
    end

    def repo_created_after_docker_cutoff?(repository)
      return true if repository.created_at.nil?
      repository.created_at > Time.parse(Travis.config.docker_default_queue_cutoff)
    end
  end
end
