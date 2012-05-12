module Travis
  module Api
    module Http
      module V2
        class Test
          include Formats

          attr_reader :job, :options

          def initialize(job, options = {})
            @job = job
            @options = options
          end

          def data
            {
              'job' => job_data(job),
              'commit' => commit_data(job.commit)
            }
          end

          private

            def job_data(job)
              {
                'id' => job.id,
                'repository_id' => job.repository_id,
                'build_id' => job.source_id,
                'commit_id' => job.commit_id,
                'number' => job.number,
                'config' => job.config.stringify_keys,
                'number' => job.number,
                'config' => job.config.stringify_keys,
                'state' => job.state.to_s,
                'result' => job.result,
                'started_at' => format_date(job.started_at),
                'finished_at' => format_date(job.finished_at),
                'log' => job.log.content,
                'sponsor' => job.sponsor.to_hash.stringify_keys,
                'worker' => job.worker
              }
            end

            def commit_data(commit)
              {
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'committed_at' => format_date(commit.committed_at),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'compare_url' => commit.compare_url,
              }
            end
        end
      end
    end
  end
end
