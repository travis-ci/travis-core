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
          comment if has_access?
        end

        def has_access?
          authenticated { GH.head(url) }
          true
        rescue GH::Error => e
          false
        end

        def comment
          authenticated { GH.post(url, :body => message) }
          info "Successfully commented on #{url}."
        rescue GH::Error => e
          error error_message(e)
        end

        def error_message(e)
          "Could not comment on #{url} (#{e.message})."
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
