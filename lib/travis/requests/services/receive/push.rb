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
              :name        => event['repository']['name'],
              :description => event['repository']['description'],
              :url         => event['repository']['_links']['html']['href'],
              :owner_name  => event['repository']['owner']['login'],
              :owner_email => event['repository']['owner']['email'],
              :owner_type  => event['repository']['owner']['type'],
              :private     => !!event['repository']['private'],
              :github_id   => event['repository']['id']
            }
          end

          def owner
            @owner ||= {
              :type      => event['repository']['owner']['type'],
              :login     => event['repository']['owner']['login'],
              :github_id => event['repository']['owner']['id']
            }
          end

          def request
            @request ||= {}
          end

          def commit
            @commit ||= if commit = last_unskipped_commit(event['commits']) ||
                                    event['commits'].last ||
                                    event['head_commit']

              {
                :commit          => commit['sha'],
                :message         => commit['message'],
                :branch          => branch,
                :tag             => tag,
                :ref             => event['ref'],
                :committed_at    => commit['date'],
                :committer_name  => commit['committer']['name'],
                :committer_email => commit['committer']['email'],
                :author_name     => commit['author']['name'],
                :author_email    => commit['author']['email'],
                :compare_url     => event['compare']
              }
            end
          end

          private

          def last_unskipped_commit(commits)
            commits.reverse.find { |commit| !skip_commit?(commit) }
          end

          def skip_commit?(commit)
            Travis::CommitCommand.new(commit['message']).skip?
          end

          def branch
            branch = extract_branch event['ref']
            if proper_tags?
              if branch.nil?
                branch = extract_branch event['base_ref']
              end
            end

            branch
          end

          def tag
            if proper_tags?
              extract_tag event['ref']
            end
          end

          def extract_branch(str)
            extract_ref(str, 'heads')
          end

          def extract_tag(str)
            extract_ref(str, 'tags')
          end

          def extract_ref(str, type)
            return unless str

            str.scan(%r{refs/#{type}/(.*?)$}).flatten.first
          end

          def repository_record
            @repository_record ||= Repository.find_by_github_id(event['repository']['id'])
          end

          def proper_tags?
            if repository_record
              Travis::Features.active?(:proper_tags, repository_record)
            else
              Travis::Features.feature_active?(:proper_tags)
            end
          end
        end
      end
    end
  end
end
