module Travis
  module Api
    module V0
      module Worker
        class Job
          class Test < Job
            include Formats

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
                'source_url' => repository.source_url,
                'last_build_id' => repository.last_build_id,
                'last_build_number' => repository.last_build_number,
                'last_build_started_at' => format_date(repository.last_build_started_at),
                'last_build_finished_at' => format_date(repository.last_build_finished_at),
                'last_build_duration' => repository.last_build_duration,
                'last_build_result' => repository.last_build_result
              }
            end
          end
        end
      end
    end
  end
end
