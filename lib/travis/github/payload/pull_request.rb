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
          @repo = gh['repository']
          @repo_owner = @repo['owner']
        end

        def action
          gh['action'].to_sym
        end

        def accept?
          [:opened, :reopened].include?(action) || action == :synchronize && head_change?
        end

        def head_change?
          head_commit && Request.last_by_head_commit(head_commit['sha']).nil?
        end

        def repository
          @repository ||= {
            :name        => @repo['name'],
            :description => @repo['description'],
            :url         => @repo['_links']['html']['href'],
            :owner_type  => @repo_owner['type'],
            :owner_name  => @repo_owner['login'],
            :owner_email => @repo_owner['email'],
            :private     => !!@repo['private']
          }
        end

        def owner
          @owner ||= {
            :type  => @repo_owner['type'],
            :login => @repo_owner['login']
          }
        end

        def request
          @request ||= {
            :payload      => payload,
            :comments_url => gh['pull_request']['_links']['comments']['href'],
            :base_commit  => base_commit['sha'],
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

        def base_commit
          gh['pull_request']['base_commit'] || { 'sha' => '' }
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
