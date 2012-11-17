require 'gh'
require 'travis/services/receive_request/instrument'
require 'travis/services/receive_request/push'
require 'travis/services/receive_request/pull_request'

module Travis
  module Services
    class ReceiveRequest < Base
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
            publish(
              :msg => "type=#{params[:event_type].inspect}",
              :type => params[:event_type],
              :accept? => target.accept?,
              :token => params[:token],
              :payload => params[:payload]
            )
          end

          def params
            target.params
          end
        end
        Instrument.attach_to(self)
    end
  end
end
