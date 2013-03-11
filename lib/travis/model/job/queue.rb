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
        language  = language.flatten.compact.first if language.is_a?(Array)
        queues.detect { |queue| queue.send(:matches?, owner, repo_name, language) } || default
      end

      protected

        def queues
          @queues ||= Array(Travis.config.queues).compact.map do |queue|
            Queue.new(*queue.values_at(*[:queue, :slug, :owner, :language]))
          end
        end

        def default
          @default ||= new(Travis.config.default_queue)
        end
    end

    attr_reader :name, :slug, :owner, :language

    protected

      def initialize(*args)
        @name, @slug, @owner, @language = *args
      end

      def matches?(owner, repo_name, language)
        matches_slug?("#{owner}/#{repo_name}") || matches_owner?(owner) || matches_language?(language)
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
  end
end
