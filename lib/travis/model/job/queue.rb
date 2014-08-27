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
        repo_name  = job.repository.try(:name)
        owner_name = job.repository.try(:owner_name)
        language   = Array(job.config[:language]).flatten.compact.first
        os         = job.config[:os]
        sudo       = allow_sudo_specification?(job.repository) ? job.config[:sudo] : nil
        owner      = job.repository.try(:owner)
        education  = owner.education if owner.respond_to? :education
        queues.detect { |queue| queue.send(:matches?, owner_name, repo_name, language, os, sudo, education) } || default
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(*[:queue, :slug, :owner, :language, :os, :sudo, :education]))
        end
      end

      def default
        @default ||= new(Travis.config.default_queue)
      end

      def allow_sudo_specification?(repository)
        Travis::Features.owner_active?(:queue_sudo, repository.owner)
      end
    end

    attr_reader :name, :slug, :owner, :language, :os, :sudo, :education

    protected

      def initialize(*args)
        @name, @slug, @owner, @language, @os, @sudo, @education = *args
      end

      def matches?(owner, repo_name, language, os = nil, sudo = nil, education = false)
        return matches_education?(education, sudo) if education
        matches_slug?("#{owner}/#{repo_name}") || matches_owner?(owner) ||
          matches_os?(os) || matches_language?(language) || matches_sudo?(sudo)
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

      def matches_sudo?(sudo)
        !self.sudo.nil? && (self.sudo == sudo)
      end

      def matches_education?(education, sudo)
        !!self.education && (self.education == education) && !self.sudo == !sudo
      end
  end
end
