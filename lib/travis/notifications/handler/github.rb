require 'core_ext/module/include'
# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  module Notifications
    module Handler

      # Adds a comment with a build notification to the pull-request the request
      # belongs to.
      class Github
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        include Logging

        include do
          attr_reader :build

          def notify(event, build, *args)
            @build = build
            send(url, payload) if send?
          end

          private

            def send?
              build.request.pull_request?
            end

            def url
              build.request.comments_url
            end

            def payload
              Api.data(build, :for => 'notifications', :version => API_VERSION)
            end

              # TODO --- extract ---

            def send(url, data)
              authenticated do
                GH.post(url, :body => message(data))
              end
              info "Successfully commented on #{url}."
            rescue Faraday::Error::ClientError => e
              error "Could not comment on #{url} (#{e.response[:status]} #{e.response[:body]})."
            end

            def authenticated(&block)
              GH.with(:token => Travis.config.github.token, &block)
            end

            TEMPLATE = 'This pull request [%{result}](%{url}) (merged %{head} into %{base}).'

            def message(data)
              TEMPLATE % {
                :result => build.passed? ? 'passes' : 'fails',
                :url => "#{Travis.config.http_host}/#{data['repository']['slug']}/builds/#{data['build']['id']}",
                :head => data['request']['head_commit'][0..7],
                :base => data['request']['base_commit'][0..7]
              }
            end
        end
      end
    end
  end
end

