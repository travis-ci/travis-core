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
          if accept?
            create && start
            request.reload
            if request.builds.count == 0
              approval = Request::Approval.new(request)
              Travis.logger.warn("[request:receive] Request #{request.id} commit=#{request.commit.try(:commit).inspect} didn't create any builds: #{approval.result}/#{approval.message}")
            else
              Travis.logger.info("[request:receive] Request #{request.id} commit=#{request.commit.try(:commit).inspect} created #{request.builds.count} builds")
            end
          else
            Travis.logger.info("[request:receive] Github event rejected: event_type=#{event_type.inspect} repo=\"#{payload.repository['owner_name']}/#{payload.repository['name']}\" commit=#{payload.commit['commit'].inspect if payload.commit} action=#{payload.action.inspect}")
          end
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
            request.start!
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
            @commit ||= repo.commits.create!(payload.commit) if payload.commit
          end

          Travis::Notification::Instrument::Services::Requests::Receive.attach_to(self)
      end
    end
  end
end
