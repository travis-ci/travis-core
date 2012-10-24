module Travis
  module Api
    module V0
      module Event
        class Build
          include Formats

          attr_reader :build, :repository, :request, :commit, :broadcasts, :options

          def initialize(build, options = {})
            @build = build
            @repository = build.repository
            @request = build.request
            @commit = build.commit
            # @broadcasts = Broadcast.by_repo(build.repository_id)
            # @options = options
          end

          def data(extra = {})
            {
              'repository' => repository_data,
              'request' => request_data,
              'commit' => commit_data,
              'build' => build_data,
              'jobs' => build.matrix.map { |job| job_data(job) }
            }
          end

          private

            def build_data
              {
                'id' => build.id,
                'repository_id' => build.repository_id,
                'commit_id' => build.commit_id,
                'number' => build.number,
                'pull_request' => build.pull_request?,
                'config' => build.config,
                'state' => build.state.to_s,
                'result' => build.result,
                'previous_result' => build.previous_result,
                'started_at' => format_date(build.started_at),
                'finished_at' => format_date(build.finished_at),
                'duration' => build.duration,
                'job_ids' => build.matrix_ids
              }
            end

            def repository_data
              {
                'id' => repository.id,
                'key' => repository.key.public_key,
                'slug' => repository.slug,
                'owner_email' => repository.owner_email,
                'admin_token' => repository_admin_token
                # 'description' => repository.description,
                # 'last_build_id' => repository.last_build_id,
                # 'last_build_number' => repository.last_build_number,
                # 'last_build_result' => repository.last_build_result,
                # 'last_build_duration' => repository.last_build_duration,
                # 'last_build_language' => repository.last_build_language,
                # 'last_build_started_at' => format_date(repository.last_build_started_at),
                # 'last_build_finished_at' => format_date(repository.last_build_finished_at),
              }
            end

            def repository_admin_token
              repository.admin.try(:github_oauth_token)
            rescue Travis::AdminMissing => error
              Travis.logger.error error.message
              nil
            end

            def request_data
              {
                'token' => request.token,
                'head_commit' => (request.head_commit || '')
                # 'base_commit' => (request.base_commit || '')
              }
            end

            def commit_data
              {
                'id' => commit.id,
                'sha' => commit.commit,
                'branch' => commit.branch,
                'message' => commit.message,
                'committed_at' => commit.committed_at,
                'author_name' => commit.author_name,
                'author_email' => commit.author_email,
                'committer_name' => commit.committer_name,
                'committer_email' => commit.committer_email,
                'compare_url' => commit.compare_url,
              }
            end

            def job_data(job)
              {
                'id' => job.id,
                'number' => job.number,
                'result' => job.result,
                'tags' => job.tags
                # 'repository_id' => job.repository_id,
                # 'build_id' => job.source_id,
                # 'commit_id' => job.commit_id,
                # 'log_id' => job.log.id,
                # 'state' => job.state.to_s,
                # 'config' => job.obfuscated_config.stringify_keys,
                # 'started_at' => format_date(job.started_at),
                # 'finished_at' => format_date(job.finished_at),
                # 'queue' => job.queue,
                # 'allow_failure' => job.allow_failure,
              }
            end

            # def broadcast_data(broadcast)
            #   {
            #     'message' => broadcast.message
            #   }
            # end
        end
      end
    end
  end
end


