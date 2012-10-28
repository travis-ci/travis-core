require 'gh'

module Travis
  module Services
    module Requests
      class Receive
        class PullRequest
          attr_reader :payload

          def initialize(payload)
            @payload = payload
          end

          def event
            @event ||= GH.load(payload)
          end

          def accept?
            return false if pull_requests_disabled?
            case action
            when :opened, :reopened then !!merge_commit
            when :synchronize       then head_change?
            else false
            end
          end

          def head_change?
            head_commit && Request.last_by_head_commit(head_commit['sha']).nil?
          end

          def repository
            @repository ||= {
              :name        => repo['name'],
              :description => repo['description'],
              :url         => repo['_links']['html']['href'],
              :owner_type  => repo_owner['type'],
              :owner_name  => repo_owner['login'],
              :owner_email => repo_owner['email'],
              :private     => !!repo['private']
            }
          end

          def owner
            @owner ||= {
              :type  => repo_owner['type'],
              :login => repo_owner['login']
            }
          end

          def request
            @request ||= {
              :payload      => payload,
              :comments_url => pull_request['_links']['comments']['href'],
              :base_commit  => base_commit['sha'],
              :head_commit  => head_commit['sha']
            }
          end

          def commit
            @commit ||= if merge_commit
              {
                :commit          => merge_commit['sha'],
                :message         => head_commit['message'],
                :branch          => pull_request['base']['ref'],
                :ref             => merge_commit['ref'],
                :committed_at    => head_commit['committer']['date'],
                :committer_name  => head_commit['committer']['name'],
                :committer_email => head_commit['committer']['email'],
                :author_name     => head_commit['author']['name'],
                :author_email    => head_commit['author']['email'],
                :compare_url     => pull_request['_links']['html']['href']
              }
            end
          end

          def pull_request
            event['pull_request']
          end

          def action
            event['action'].to_sym
          end

          def base_commit
            pull_request['base_commit'] || { 'sha' => '' }
          end

          def head_commit
            pull_request['head_commit']
          end

          def merge_commit
            pull_request['merge_commit']
          end

          def pull_requests_disabled?
            Travis::Features.feature_deactivated?(:pull_requests)
          end

          private

            def repo
              @repo ||= event['repository']
            end

            def repo_owner
              @repo_owner ||= repo['owner']
            end
        end
      end
    end
  end
end
