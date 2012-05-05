module Travis
  module Api
    module Json
      module Http
        class Build
          class Job
            include Formats

            attr_reader :job, :commit

            def initialize(job)
              @job = job
              @commit = job.commit
            end

            def data
              {
                'id' => job.id,
                'repository_id' => job.repository_id,
                'number' => job.number,
                'config' => job.config.stringify_keys,
                'result' => job.status,
                'started_at' => format_date(job.started_at),
                'finished_at' => format_date(job.finished_at),
              }
            end
          end
        end
      end
    end
  end
end
