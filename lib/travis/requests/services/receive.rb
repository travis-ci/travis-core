require 'gh'

module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        autoload :PullRequest, 'travis/requests/services/receive/pull_request'
        autoload :Push,        'travis/requests/services/receive/push'

        extend Travis::Instrumentation

        register :receive_request

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
            commit = payload.commit['commit'].inspect if payload.commit rescue nil
            Travis.logger.info("[request:receive] Github event rejected: event_type=#{event_type.inspect} repo=\"#{payload.repository['owner_name']}/#{payload.repository['name']}\" commit=#{commit} action=#{payload.action.inspect}")
          end
          request
        end
        instrument :run

        def accept?
          payload.accept?
        rescue GH::Error(response_status: 404) => e
          slug = payload.repository.values_at(:owner_name, :name).join('/')
          Travis.logger.warn "the following payload for #{slug} could not be accepted as a 404 response code was returned by GitHub: #{payload.inspect}"
          false
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
            @owner ||= begin
              type = payload.owner[:type] == 'User' ? 'user' : 'org'
              run_service(:"github_find_or_create_#{type}", payload.owner)
            end
          end

          def repo
            @repo ||= run_service(:github_find_or_create_repo, payload.repository.merge(:owner => owner))
          end

          def commit
            @commit ||= repo.commits.create!(payload.commit) if payload.commit
          end

          class Instrument < Notification::Instrument
            def run_completed
              params = target.params
              publish(
                :msg => "type=#{params[:event_type].inspect}",
                :type => params[:event_type],
                :accept? => target.accept?,
                :payload => params[:payload]
              )
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
