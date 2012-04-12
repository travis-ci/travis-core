class Request
  module Payload
    module Github
      class Push
        attr_reader :payload, :gh, :token

        def initialize(payload, token)
          @payload = payload
          @gh = GH.load(payload)
          @token = token
        end

        def accept?
          true
        end

        def repository
          @repository ||= {
            :name        => gh['repository']['name'],
            :description => gh['repository']['description'],
            :url         => gh['repository']['_links']['html']['href'],
            :owner_name  => gh['repository']['owner']['login'],
            :owner_email => gh['repository']['owner']['email'],
            :owner_type  => gh['repository']['owner']['type'],
            :private     => !!gh['repository']['private']
          }
        end

        def owner
          @owner ||= {
            :type  => gh['repository']['owner']['type'],
            :login => gh['repository']['owner']['login']
          }
        end

        def request
          @request ||= {
            :payload => payload,
            :token   => token
          }
        end

        def commit
          @commit ||= if commit = gh['commits'].first
            {
              :commit          => commit['sha'],
              :message         => commit['message'],
              :branch          => gh['ref'].split('/').last,
              :ref             => gh['ref'],
              :committed_at    => commit['date'],
              :committer_name  => commit['committer']['name'],
              :committer_email => commit['committer']['email'],
              :author_name     => commit['author']['name'],
              :author_email    => commit['author']['email'],
              :compare_url     => gh['compare']
            }
          end
        end
      end
    end
  end
end
