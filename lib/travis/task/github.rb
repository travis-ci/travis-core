# backports 1.9 style string interpolation. can be removed once hub runs in 1.9 mode
require 'i18n/core_ext/string/interpolate'

module Travis
  class Task

    # Adds a comment with a build notification to the pull-request the request
    # belongs to.
    class Github < Task
      include do
        attr_reader :url, :data

        def initialize(url, data)
          @url = url
          @data = data
        end

        def run
          authenticated do
            GH.post(url, :body => message(data))
          end
          info "Successfully commented on #{url}."
        rescue Faraday::Error::ClientError => e
          error "Could not comment on #{url} (#{e.response[:status]} #{e.response[:body]})."
        end

        private

          def authenticated(&block)
            GH.with(:token => Travis.config.github.token, &block)
          end

          TEMPLATE = 'This pull request [%{result}](%{url}) (merged %{head} into %{base}).'

          def message(data)
            TEMPLATE % {
              :result => data['build']['result'] ? 'passes' : 'fails',
              :url => "#{Travis.config.http_host}/#{data['repository']['slug']}/builds/#{data['build']['id']}",
              :head => data['request']['head_commit'][0..7],
              :base => data['request']['base_commit'][0..7]
            }
          end
      end
    end
  end
end
