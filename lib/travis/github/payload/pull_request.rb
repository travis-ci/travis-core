require 'gh'

module Travis
  module Github
    module Payload
      class PullRequest
        attr_reader :payload, :gh

        def initialize(payload)
          @payload = payload

          GH.reset # FIXME: solve this somehow differently
          @gh = GH.load(payload)
        end

        def action
          gh['action'].to_sym
        end

        def accept?
          action == :opened || action == :synchronize && head_change?
        end

        def head_change?
          Request.last_by_head_commit(head_commit['sha']).nil?
        end

        def repository
          @repository ||= {
            :name        => gh['repository']['name'],
            :description => gh['repository']['description'],
            :url         => gh['repository']['_links']['html']['href'],
            :owner_type  => gh['repository']['owner']['type'],
            :owner_name  => gh['repository']['owner']['login'],
            :owner_email => gh['repository']['owner']['email'],
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
            :payload      => payload,
            :comments_url => gh['pull_request']['_links']['comments']['href'],
            :head_commit  => head_commit['sha']
          }
        end

        def commit
          @commit ||= if merge_commit
            {
              :commit          => merge_commit['sha'],
              :message         => head_commit['message'],
              :branch          => gh['pull_request']['base']['ref'],
              :ref             => merge_commit['ref'],
              :committed_at    => head_commit['committer']['date'],
              :committer_name  => head_commit['committer']['name'],
              :committer_email => head_commit['committer']['email'],
              :author_name     => head_commit['author']['name'],
              :author_email    => head_commit['author']['email'],
              :compare_url     => gh['pull_request']['_links']['html']['href']
            }
          end
        end

        def head_commit
          gh['pull_request']['head_commit']
        end

        def merge_commit
          gh['pull_request']['merge_commit']
        end
      end
    end
  end
end
