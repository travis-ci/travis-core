class Job

  # Encapsulates logic for figuring out which queue a given job needs to go
  # into.
  #
  # Queue names for Job::Test instances are configured in `Travis.config` and
  # are determined based on the repository slug (e.g. 'rails/rails' has its own
  # queue) or the language given in the configuration (`.travis.yml`) and
  # default to 'builds.common'.
  class Queue
    class << self
      def for(job)
        slug = job.repository.try(:slug)
        owner = job.repository.try(:owner_name)
        language = job.config[:language]
        language = language.flatten.compact.first if language.is_a?(Array)
        queues.detect { |queue| queue.send(:matches?, owner, slug, language) } || default
      end

      protected

        def queues
          @queues ||= Array(Travis.config.queues).compact.map do |queue|
            Queue.new(*queue.values_at(*[:queue, :slug, :language]))
          end
        end

        def default
          @default ||= new('builds.common')
        end
    end

    attr_reader :name, :slug, :owner, :language

    protected

      def initialize(*args)
        @name, @slug, @language = *args
      end

      def matches?(owner, slug, language)
        matches_slug?(slug) || matches_owner?(owner) || matches_language?(language)
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
