module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class Api
          VALIDATION_ERRORS = {
            repo: 'Repository data is not present in payload',
            user: 'User data is not present in payload'
          }
          attr_reader :event

          def initialize(event)
            @event = event
          end

          def accept?
            true
          end

          def validate!
            error(:repo) if event['repository'].nil?
            error(:user) if event['user'].nil?
          end

          def action
            nil
          end

          # TODO We'd never want to create a repo or user in this case, and I
          # guess we probably don't want to do that anymore for other request
          # types either? The repo and repo owner should always already exist,
          # right? That would mean lots of code could be cleaned up here, and
          # GitHub::Services::FindOrCreateRepo could be ditched.
          def repository
            @repository ||= {
              :name        => repo_data['name'],
              :description => repo_data['description'],
              :url         => repo_data['_links']['html']['href'],
              :owner_name  => repo_data['owner']['login'],
              :owner_email => repo_data['owner']['email'],
              :owner_type  => repo_data['owner']['type'],
              :private     => !!repo_data['private'],
              :github_id   => repo_data['id']
            }
          end

          def owner
            @owner ||= {
              :type      => 'User',
              :login     => user.login,
              :github_id => user.github_id
            }
          end

          def request
            @request ||= {
              :config => event['config']
            }
          end

          def commit
            @commit ||= begin
              {
                :commit          => commit_data['sha'],
                :message         => commit_data['commit']['message'],
                :branch          => branch,
                :ref             => nil,                                        # TODO verify that we do not need this
                :committed_at    => commit_data['commit']['committer']['date'], # TODO in case of API requests we'd want to display the timestamp of the incoming request
                :committer_name  => commit_data['commit']['committer']['name'],
                :committer_email => commit_data['commit']['committer']['email'],
                :author_name     => commit_data['commit']['author']['name'],
                :author_email    => commit_data['commit']['author']['email'],
                :compare_url     => nil                                         # TODO verify that we do not need this
              }
            end
          end

          private

            def gh
              Github.authenticated(user)
            end

            def user
              @user ||= User.find(event['user']['id'])
            end

            def slug
              "#{event['repository']['owner_name']}/#{event['repository']['name']}"
            end

            def branch
              event['branch'] || 'master'
            end

            def repo_data
              @repo_data ||= gh["repos/#{slug}"] # TODO protect from 404 (GH::Error?)
            end

            def commit_data
              @commit_data ||= gh["repos/#{slug}/commits?sha=#{branch}&per_page=1"].first # TODO protect from 404 (GH::Error?)
            end

            def error(type)
              raise PayloadValidationError, VALIDATION_ERRORS[type]
            end
        end
      end
    end
  end
end
