module Travis
  module Api
    module V2
      module Http
        class Jobs
          include Formats

          attr_reader :jobs

          def initialize(jobs, options = {})
            @jobs = jobs
          end

          def data
            { 'jobs' => jobs.map { |job| job_data(job) } }
          end

          private

            def job_data(job)
              {
                'id' => job.id,
                'repository_id' => job.repository_id,
                'number' => job.number,
                'state' => job.state.to_s,
                'queue' => job.queue,
              }
            end
        end
      end
    end
  end
end
