module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class Push
          attr_reader :event

          def initialize(event)
            @event = event
          end

          def accept?
            true
          end

          def validate!
            if event['repository'].nil?
              raise PayloadValidationError, "Repository data is not present in payload"
            end
          end

          def action
            nil
          end

          def repository
            @repository ||= {
              name:        event['repository']['name'],
              description: event['repository']['description'],
              url:         event['repository']['_links']['html']['href'],
              owner_name:  event['repository']['owner']['login'],
              owner_email: event['repository']['owner']['email'],
              owner_type:  event['repository']['owner']['type'],
              private:     !!event['repository']['private'],
              github_id:   event['repository']['id']
            }
          end

          def request
            @request ||= {}
          end

          def commit
            @commit ||= commit_data && {
              commit:          commit_data['sha'],
              message:         commit_data['message'],
              branch:          event['ref'].split('/', 3).last,
              ref:             event['ref'],
              committed_at:    commit_data['date'],
              committer_name:  commit_data['committer']['name'],
              committer_email: commit_data['committer']['email'],
              author_name:     commit_data['author']['name'],
              author_email:    commit_data['author']['email'],
              compare_url:     event['compare']
            }
          end

          private

            def commit_data
              last_unskipped_commit(event['commits']) || event['commits'].last || event['head_commit']
            end

            def last_unskipped_commit(commits)
              commits.reverse.find { |commit| !skip_commit?(commit) }
            end

            def skip_commit?(commit)
              Travis::CommitCommand.new(commit['message']).skip?
            end
        end
      end
    end
  end
end
