module Travis
  module Api
    module Webhook
      class Build
        class Finished < Build
          class Job
            include Formats

            attr_reader :job, :commit

            def initialize(job)
              @job = job
              @commit = job.commit
            end

            def data(options = {})
              data = {
                'id' => job.id,
                'repository_id' => job.repository_id,
                'parent_id' => job.source_id,
                'number' => job.number,
                'state' => job.state.to_s,
                'config' => job.config,
                'status' => job.result,
                'result' => job.result,
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'compare_url' => commit.compare_url,
                'committed_at' => format_date(commit.committed_at),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email
              }
              data['log'] = job.log.try(:content) || '' unless options[:bare]
              data['started_at'] = format_date(job.started_at) if job.started?
              data['finished_at'] = format_date(job.finished_at) if job.finished?
              data
            end
          end
        end
      end
    end
  end
end
