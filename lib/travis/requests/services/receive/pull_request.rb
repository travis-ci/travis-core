module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class PullRequest
          attr_reader :event

          def initialize(event)
            @event = event
          end

          def accept?
            return false if disabled?
            case action
            when :opened, :reopened then !!merge_commit
            when :synchronize       then head_change?
            else false
            end
          end

          def validate!
            if event['repository'].nil?
              raise PayloadValidationError, "Repository data is not present in payload"
            end
          end

          def disabled?
            Travis::Features.feature_deactivated?(:pull_requests)
          end

          def head_change?
            head_commit && ::Request.last_by_head_commit(head_commit['sha']).nil?
          end

          def repository
            @repository ||= {
              :name        => repo['name'],
              :description => repo['description'],
              :url         => repo['_links']['html']['href'],
              :owner_type  => repo_owner['type'],
              :owner_name  => repo_owner['login'],
              :owner_email => repo_owner['email'],
              :private     => !!repo['private'],
              :github_id   => repo['id']
            }
          end

          def owner
            @owner ||= {
              :type      => repo_owner['type'],
              :login     => repo_owner['login'],
              :github_id => repo_owner['id']
            }
          end

          # def admin
          #   @admin ||= begin
          #     repo = Repository.where(owner_name: repository['owner_name'], name: repository['name']).first
          #     repo.admin
          #   end
          # end

          def request
            @request ||= {
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
