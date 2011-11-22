class Job
  class Queue
    class << self
      def for(job)
        slug = job.repository.slug
        target, language = job.config.values_at(:target, :language)
        queues.detect { |queue| queue.matches?(slug, target, language) } || default_queue
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(*[:queue, :slug, :target, :language]))
        end
      end

      def default_queue
        @default_queue ||= Queue.new('builds.common')
      end
    end

    attr_reader :name, :slug, :target, :language

    def initialize(*args)
      @name, @slug, @target, @language = *args
    end

    def matches?(slug, target, language)
      matches_slug?(slug) || matches_language?(language) # || matches_target?(target)
    end

    def queue
      name
    end

    protected

      def matches_slug?(slug)
        !!self.slug && (self.slug == slug)
      end

      def matches_target?(target)
        !!self.target && (self.target == target)
      end

      def matches_language?(language)
        !!self.language && (self.language == language)
      end
  end
end
