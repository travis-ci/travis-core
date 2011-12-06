class Job
  class Queue
    class << self
      def for(job)
        if job.is_a?(Job::Configure)
          configure
        else
          slug = job.repository.slug
          language = job.config[:language]
          queues.detect { |queue| queue.matches?(slug, language) } || default
        end
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(*[:queue, :slug, :language]))
        end
      end

      def configure
        @configure || new('builds.configure')
      end

      def default
        @default ||= new('builds.common')
      end
    end

    attr_reader :name, :slug, :language

    def initialize(*args)
      @name, @slug, @language = *args
    end

    def matches?(slug, language)
      matches_slug?(slug) || matches_language?(language)
    end

    def queue
      name
    end

    protected

      def matches_slug?(slug)
        !!self.slug && (self.slug == slug)
      end

      def matches_language?(language)
        !!self.language && (self.language == language)
      end
  end
end

