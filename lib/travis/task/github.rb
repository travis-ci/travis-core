# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  class Task

    # Adds a comment with a build notification to the pull-request the request
    # belongs to.
    class Github < Task
      TEMPLATE = 'This pull request [%{result}](%{url}) (merged %{head} into %{base}).'

      def url
        options[:url]
      end

      def message
        @message ||= TEMPLATE % {
          :result => pretty_result,
          :url => "#{Travis.config.http_host}/#{data['repository']['slug']}/builds/#{data['build']['id']}",
          :head => data['request']['head_commit'][0..7],
          :base => data['request']['base_commit'][0..7]
        }
      end

      private

        def process
          authenticated do
            GH.post(url, :body => message)
          end
          info "Successfully commented on #{url}."
        rescue Faraday::Error::ClientError => e
          message = e.message
          message += ": #{e.response[:status]} #{e.response[:body]}" if e.response
          error "Could not comment on #{url} (#{message})."
        end

        def authenticated(&block)
          GH.with(http_options, &block)
        end

        def http_options
          super.merge(:token => Travis.config.github.token)
        end

        # TODO move to Build::Messages
        def pretty_result
          data['build']['result'] == 0 ? 'passes' : 'fails'
        end

        Notification::Instrument::Task::Github.attach_to(self)
    end
  end
end
