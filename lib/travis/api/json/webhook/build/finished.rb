module Travis
  module Api
    module Json
      module Webhook
        class Build
          class Finished < Build
            class Job
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
                  'state' => job.state,
                  'config' => job.config,
                  'status' => job.status,
                  'result' => job.status,
                  'commit' => commit.commit,
                  'branch' => commit.branch,
                  'message' => commit.message,
                  'compare_url' => commit.compare_url,
                  'committed_at' => commit.committed_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                  'author_name' => commit.author_name,
                  'author_email' => commit.author_email,
                  'committer_name' => commit.committer_name,
                  'committer_email' => commit.committer_email
                }
                data['log'] = job.log.try(:content) || '' unless options[:bare]
                data['started_at'] = job.started_at.strftime('%Y-%m-%dT%H:%M:%SZ') if job.started?
                data['finished_at'] = job.finished_at.strftime('%Y-%m-%dT%H:%M:%SZ') if job.finished?
                data
              end
            end

            def data(options = {})
              {
                'id' => build.id,
                'repository' => repository_data,
                'number' => build.number,
                'config' => build.config.stringify_keys,
                'status' => build.status,
                'status_message' => build.status_message,
                'started_at' => build.started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'finished_at' => build.started_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'duration' => build.duration,
                'commit' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'compare_url' => commit.compare_url,
                'committed_at' => commit.committed_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'matrix' => build.matrix.map { |job| Job.new(job).data(options) }
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'name' => repository.name,
                'owner_name' => repository.owner_name,
                'url' => repository.url
              }
            end
          end
        end
      end
    end
  end
end


