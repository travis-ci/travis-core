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
        config = {
          owner:    job.repository.try(:owner_name),
          slug:     job.repository.try(:slug),
          language: Array(job.config[:language]).flatten.compact.first,
          os:       job.config[:os],
          stack:    job.config[:stack]
        }

        queues.detect { |queue| queue.send(:matches?, config) } || default
      end

      def default
        @default ||= new(Travis.config.default_queue)
      end

      def queues
        @queues ||= Array(Travis.config.queues).compact.map do |queue|
          Queue.new(*queue.values_at(:queue, *ATTRS))
        end
      end
    end

    ATTRS = [:slug, :owner, :language, :os, :stack]

    attr_reader :name, *ATTRS

    private

      def initialize(*args)
        @name, @slug, @owner, @language, @os, @stack = *args
      end

      def matches?(config)
        config.inject(false) do |result, (name, value)|
          result || matches_attr?(name, value)
        end
      end

      def matches_attr?(name, value)
        !!send(name) && (send(name) == value)
      end
  end
end
