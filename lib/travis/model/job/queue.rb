class Job

  # Encapsulates logic for figuring out which queue a given job needs to go
  # into.
  #
  # The queue name for Job::Configure instances always is 'builds.configure'.
  #
  # Queue names for Job::Test instances are configured in `Travis.config` and
  # are determined based on the repository slug (e.g. 'rails/rails' has its own
  # queue) or the language given in the configuration (`.travis.yml`) and
  # default to 'builds.common'.
  class Queue
    class << self
      def for(job)
        if job.is_a?(Job::Configure)
          configure
        else
          slug = job.repository.try(:slug)
          language = job.config[:language]
          queues.detect { |queue| queue.send(:matches?, slug, language) } || default
        end
      end

      protected

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

    protected

      def initialize(*args)
        @name, @slug, @language = *args
      end

      def matches?(slug, language)
        matches_slug?(slug) || matches_language?(language)
      end

      def queue
        name
      end

      def matches_slug?(slug)
        !!self.slug && (self.slug == slug)
      end

      def matches_language?(language)
        !!self.language && (self.language == language)
      end
  end
end

