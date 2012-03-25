class Job

  # Executes a test job (i.e. runs a test suite) remotely and keeps tabs about
  # state changes throughout its lifecycle in the database.
  #
  # Job::Test belongs to a Build as part of the build matrix and will be
  # created with the Build.
  #
  # As test logs are streamed from the worker to both the application (db) and
  # browsers this class also implements a public `append_log!` method that both
  # appends log updates efficiently and notifies the event handlers (see
  # `Job::Test::States.append_log!`)
  class Test < Job
    autoload :States, 'travis/model/job/test/states'

    include Test::States, Sponsors, Tagging

    class << self
      def append_log!(id, chars)
        job = find(id)
        job.append_log!(chars) unless job.finished?
      end
    end

    def append_log!(chars)
      Artifact::Log.append(id, chars)
      super
    end
  end
end
