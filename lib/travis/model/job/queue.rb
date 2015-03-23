class Job

  # Encapsulates logic for figuring out which queue a given job needs to go
  # into.
  #
  # Queue names for Job::Test instances are configured in `Travis.config` and
  # are determined based on the repository slug (e.g. 'rails/rails' has its own
  # queue) or the language given in the configuration (`.travis.yml`) and
  # default to 'builds.linux'.
  class Queue
    class << self
      def for(job)
        repo_name       = job.repository.try(:name)
        owner_name      = job.repository.try(:owner_name)
        language        = Array(job.config[:language]).flatten.compact.first
        os              = job.config[:os]
        sudo            = job.config[:sudo]
        sudo_detected   = sudo_detected?(job.config)
        owner           = job.repository.try(:owner)
        education       = Travis::Github::Education.education_queue?(owner)
        dist            = job.config[:dist]
        repo_created_at = job.repository.created_at
        queues.detect { |queue| queue.send(:matches?, owner_name, repo_name, language, os, sudo, education, dist, repo_created_at, sudo_detected) } || default
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(*[:queue, :slug, :owner, :language, :os, :sudo, :education, :dist]))
        end
      end

      def default
        @default ||= new(Travis.config.default_queue)
      end

      def sudo_detected?(config)
        config.values_at(*custom_stages).compact.map do |value|
          Array(value).reject { |s| s =~ /\s*#.*/ }.map { |s| s =~ /\b(sudo|ping)\b/ }.any?
        end.any?
      end

      def custom_stages
        @custom_stages ||= %w(
          before_install
          install
          before_script
          script
          before_cache
          after_success
          after_failure
          after_script
        ).map(&:to_sym)
      end
    end

    attr_reader :name, :slug, :owner, :language, :os, :sudo, :education, :dist

    protected

      def initialize(*args)
        @name, @slug, @owner, @language, @os, @sudo, @education, @dist = *args
      end

      def matches?(owner, repo_name, language, os = nil, sudo = nil, education = false, dist = nil, repo_created_at = nil, sudo_detected = false)
        return matches_education?(education) if education
        matches_slug?("#{owner}/#{repo_name}") || matches_owner?(owner) || matches_os?(os) ||
          matches_language?(language) || matches_sudo?(sudo, repo_created_at, sudo_detected) || matches_dist?(dist)
      end

      def queue
        name
      end

      def matches_slug?(slug)
        !!self.slug && (self.slug == slug)
      end

      def matches_owner?(owner)
        !!self.owner && (self.owner == owner)
      end

      def matches_language?(language)
        !!self.language && (self.language == language)
      end

      def matches_os?(os)
        !!self.os && (self.os == os)
      end

      def matches_sudo?(sudo, repo_created_at, sudo_detected)
        sudo = !!sudo if repo_is_default_docker?(repo_created_at, sudo_detected)
        !self.sudo.nil? && (self.sudo == sudo)
      end

      def repo_is_default_docker?(repo_created_at, sudo_detected)
        return false unless Travis::Features.feature_active?(:docker_default_queue)
        !sudo_detected && (
          repo_created_at.nil? ||
          repo_created_at > Time.parse(Travis.config.docker_default_queue_cutoff)
        )
      end

      def matches_education?(education)
        !!self.education && (self.education == education)
      end

      def matches_dist?(dist)
        !!self.dist && (self.dist == dist)
      end
  end
end
