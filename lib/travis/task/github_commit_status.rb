# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  class Task

    # Adds a comment with a build notification to the pull-request the request
    # belongs to.
    class GithubCommitStatus < Task

      def url
        options[:url]
      end

      def build_url
        options[:build_url]
      end

      def sha
        options[:sha]
      end

      private

        def process
          authenticated do
            GH.post(url, :sha => sha, :target_url => build_url, :state => state)
          end
          info "Successfully updated the PR status on #{url}."
        rescue Faraday::Error::ClientError => e
          message = e.message
          message += ": #{e.response[:status]} #{e.response[:body]}" if e.response
          error "Could not update the PR status on #{url} (#{message})."
        end

        def authenticated(&block)
          GH.with(http_options, &block)
        end

        def http_options
          super.merge(:token => options[:token])
        end

        # TODO move to Build::Messages
        def state
          data['build']['result'] == 0 ? 'success' : 'failure'
        end

        Notification::Instrument::Task::GithubCommitStatus.attach_to(self)
    end
  end
end
