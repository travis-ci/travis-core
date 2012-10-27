module Travis
  module Addons
    module GithubStatus

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Task < Travis::Task
        STATES = {
          nil => 'pending',
          0   => 'success',
          1   => 'failure'
        }

        DESCRIPTIONS = {
          nil => 'The Travis build is in progress',
          0   => 'The Travis build passed',
          1   => 'The Travis build failed'
        }

        def url
          "/repos/#{repository[:slug]}/statuses/#{sha}"
        end

        private

          def process
            authenticated do
              GH.post(url, :state => state, :description => description, :target_url => target_url)
            end
          rescue GH::Error => e
            error "Could not update the PR status on #{GH.api_host + url} (#{e.message})."
          end

          def target_url
            "#{Travis.config.http_host}/#!/#{repository[:slug]}/builds/#{build[:id]}"
          end

          def sha
            pull_request? ? request[:head_commit] : commit[:sha]
          end

          def description
            DESCRIPTIONS[build[:result]]
          end

          def state
            STATES[build[:result]]
          end

          def authenticated(&block)
            GH.with(http_options, &block)
          end

          def http_options
            super.merge(token: params[:token])
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end

