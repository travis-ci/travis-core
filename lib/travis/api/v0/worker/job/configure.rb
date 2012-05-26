module Travis
  module Api
    module V0
      module Worker
        class Job
          class Configure < Job
            def data
              {
                'type' => 'configure',
                'job' => job_data,
                # TODO remove this after workers respond to the job key
                'build' => job_data,
                'repository' => repository_data,
                'queue' => job.queue
              }
            end

            def job_data
              {
                'id' => job.id,
                'commit' => commit.commit,
                'branch' => commit.branch,
                'config_url' => commit.config_url
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug
              }
            end
          end
        end
      end
    end
  end
end
