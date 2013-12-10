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
        repo_name = job.repository.try(:name)
        owner     = job.repository.try(:owner_name)
        language  = job.config[:language]
        language  = Array(language).flatten.compact.first
        os        = job.config[:os]
        queues.detect { |queue| queue.send(:matches?, owner, repo_name, language, os) } || default
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(*[:queue, :slug, :owner, :language, :os]))
        end
      end

      def default
        @default ||= new(Travis.config.default_queue)
      end
    end

    attr_reader :name, :slug, :owner, :language, :os

    protected

      def initialize(*args)
        @name, @slug, @owner, @language, @os = *args
      end

      def matches?(owner, repo_name, language, os = nil)
        matches_slug?("#{owner}/#{repo_name}") || matches_owner?(owner) ||
          matches_os?(os) || matches_language?(language)
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
  end
end
