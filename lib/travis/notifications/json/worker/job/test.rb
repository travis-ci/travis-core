module Travis
  module Notifications
    module Json
      module Worker
        class Job
          class Test < Job
            def data
              {
                'type' => 'test',
                'build' => build_data,
                'repository' => repository_data,
                'config' => job.config,
                'queue' => job.queue
              }
            end

            def build_data
              data = {
                'id' => job.id,
                'number' => job.number,
                'commit' => commit.commit,
                'branch' => commit.branch
              }
              data.merge!('ref' => commit.ref) if commit.pull_request?
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
