module Travis
  module Api
    module Json
      module Http
        module Job
          class Test
            include Formats

            attr_reader :job, :commit

            def initialize(job, options = {})
              @job = job
              @commit = job.commit
            end

            def data
              {
                'id' => job.id,
                'number' => job.number,
                'config' => job.config.stringify_keys,
                'repository_id' => job.repository_id,
                'build_id' => job.source_id,
                'number' => job.number,
                'config' => job.config.stringify_keys,
                'state' => job.state.to_s,
                'result' => job.result,
                'status' => job.result,
                'started_at' => format_date(job.started_at),
                'finished_at' => format_date(job.finished_at),
                'log' => job.log.content,
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'committed_at' => format_date(commit.committed_at),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'compare_url' => commit.compare_url,
                'sponsor' => job.sponsor.to_hash.stringify_keys,
                'worker' => job.worker
              }
            end
          end
        end
      end
    end
  end
end
