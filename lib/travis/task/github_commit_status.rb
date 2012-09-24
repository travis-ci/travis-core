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

      def description
        "The Travis build #{friendly_state}"
      end

      private

        def process
          authenticated do
            GH.post(url, :target_url => build_url, :state => state, :description => description)
          end
          info "Successfully updated the PR status on #{full_url}."
        rescue GH::Error => e
          error "Could not update the PR status on #{full_url} (#{e.message})."
        end

        def authenticated(&block)
          GH.with(http_options, &block)
        end

        def http_options
          super.merge(:token => options[:token])
        end

        # TODO move to Build::Messages
        def state
          case data['build']['result']
          when nil
            'pending'
          when 0
            'success'
          when 1
            'failure'
          end
        end

        def friendly_state
          case data['build']['result']
          when nil
            'is in progress'
          when 0
            'passed'
          when 1
            'failed'
          end
        end

        def full_url
          GH.api_host + url
        end

        Notification::Instrument::Task::GithubCommitStatus.attach_to(self)
    end
  end
end
