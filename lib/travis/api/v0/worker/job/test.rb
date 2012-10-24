module Travis
  module Api
    module V0
      module Worker
        class Job
          class Test < Job
            def data
              {
                'type' => 'test',
                # TODO legacy. remove this once workers respond to a 'job' key
                'build' => job_data,
                'job' => job_data,
                'repository' => repository_data,
                'config' => job.decrypted_config,
                'queue' => job.queue,
                'uuid' => Travis.uuid
              }
            end

            def job_data
              data = {
                'id' => job.id,
                'number' => job.number,
                'commit' => commit.commit,
                'branch' => commit.branch,
                'ref' => commit.pull_request? ? commit.ref : nil,
                'state' => job.state.to_s
              }
              data['pull_request'] = commit.pull_request? ? commit.pull_request_number : false
              data
            end

            def repository_data
              {
                'id' => repository.id,
                'slug' => repository.slug,
                'source_url' => repository.source_url
              }
            end
          end
        end
      end
    end
  end
end
