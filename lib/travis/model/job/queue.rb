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
        owner      = job.repository.try(:owner_name)
        language   = Array(job.config[:language]).flatten.compact.first
        os         = job.config[:os]
        super_user = allow_super_user_specification?(job.repository) ? job.config[:super_user] : nil
        queues.detect { |queue| queue.send(:matches?, owner, repo_name, language, os, super_user) } || default
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(*[:queue, :slug, :owner, :language, :os, :super_user]))
        end
      end

      def default
        @default ||= new(Travis.config.default_queue)
      end

      def allow_super_user_specification?(repository)
        Travis::Features.owner_active?(:queue_super_user, repository.owner)
      end
    end

    attr_reader :name, :slug, :owner, :language, :os, :super_user

    protected

      def initialize(*args)
        @name, @slug, @owner, @language, @os, @super_user = *args
      end

      def matches?(owner, repo_name, language, os = nil, super_user = nil)
        matches_slug?("#{owner}/#{repo_name}") || matches_owner?(owner) ||
          matches_os?(os) || matches_language?(language) || matches_super_user?(super_user)
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

      def matches_super_user?(super_user)
        !self.super_user.nil? && (self.super_user == super_user)
      end
  end
end
