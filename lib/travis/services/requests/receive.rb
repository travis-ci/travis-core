require 'gh'

module Travis
  module Services
    module Requests
      class Receive < Base
        autoload :PullRequest, 'travis/services/requests/receive/pull_request'
        autoload :Push,        'travis/services/requests/receive/push'

        extend Travis::Instrumentation

        class << self
          def payload_for(type, data)
            event = GH.load(data)
            const_get(type.camelize).new(event)
          end
        end

        attr_reader :request

        def run
          create && start if accept?
          request
        end
        instrument :run

        def accept?
          payload.accept?
        end

        private

          def create
            @request = repo.requests.create!(payload.request.merge(
              :payload => params[:payload],
              :event_type => event_type,
              :state => :created,
              :commit => commit,
              :owner => owner,
              :token => params[:token]
            ))
          end

          def start
            request.start! if request
          end

          def payload
            @payload ||= self.class.payload_for(event_type, params[:payload])
          end

          def event_type
            @event_type ||= (params[:event_type] || 'push').gsub('-', '_')
          end

          def owner
            @owner ||= service(payload.owner[:type].pluralize, :find_by_github, payload.owner).run
          end

          def repo
            @repo ||= service(:repositories, :find_by_github, payload.repository.merge(:owner => owner)).run
          end

          def commit
            @commit = repo.commits.create!(payload.commit) if payload.commit
          end

          Travis::Notification::Instrument::Services::Requests::Receive.attach_to(self)
      end
    end
  end
end
