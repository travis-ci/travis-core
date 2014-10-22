require 'gh'
require 'travis/services/base'
require 'travis/model/request/approval'
require 'travis/notification/instrument'

require "travis/travis_yml_stats"

module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        require 'travis/requests/services/receive/api'
        require 'travis/requests/services/receive/pull_request'
        require 'travis/requests/services/receive/push'

        extend Travis::Instrumentation

        class PayloadValidationError < StandardError; end

        register :receive_request

        class << self
          def payload_for(type, data)
            data = GH.load(data)
            const_get(type.camelize).new(data)
          end
        end

        attr_reader :request

        def run
          if accept?
            create && start
            store_config_info if verify
          else
            rejected
          end
          request
        end
        instrument :run

        def accept?
          payload.validate!
          validate!
          payload.accept?
        rescue GH::Error(response_status: 404) => e
          slug = payload.repository.values_at(:owner_name, :name).join('/')
          Travis.logger.warn "the following payload for #{slug} could not be accepted as a 404 response code was returned by GitHub: #{payload.inspect}"
          false
        rescue PayloadValidationError => e # TODO should use try/catch instead of raise/rescue
          e.message << ", github-guid=#{github_guid}, event-type=#{event_type}"
          raise e
        end

        private

          def validate!
            raise PayloadValidationError, "Repository not found: #{slug}" unless repo
          end

          def create
            @request = repo.requests.create!(payload.request.merge(
              :payload => params[:payload],
              :event_type => event_type,
              :state => :created,
              :commit => commit,
              :owner => repo.owner,
              :token => params[:token]
            ))
          end

          def start
            request.start!
          end

          def verify
            request.reload
            if request.builds.count == 0
              approval = Request::Approval.new(request)
              Travis.logger.warn("[request:receive] Request #{request.id} commit=#{request.commit.try(:commit).inspect} didn't create any builds: #{approval.result}/#{approval.message}")
              false
            else
              Travis.logger.info("[request:receive] Request #{request.id} commit=#{request.commit.try(:commit).inspect} created #{request.builds.count} builds")
              true
            end
          end

          def rejected
            commit = payload.commit['commit'].inspect if payload.commit rescue nil
            Travis.logger.info("[request:receive] Github event rejected: event_type=#{event_type.inspect} repo=\"#{payload.repository['owner_name']}/#{payload.repository['name']}\" commit=#{commit} action=#{payload.action.inspect}")
          end

          def payload
            @payload ||= self.class.payload_for(event_type, params[:payload])
          end

          def github_guid
            params[:github_guid]
          end

          def event_type
            @event_type ||= (params[:event_type] || 'push').gsub('-', '_')
          end

          def repo
            @repo ||= run_service(:find_repo, payload.repository)
          end

          def slug
            payload.repository.values_at(:owner_name, :name).join('/')
          end

          def commit
            @commit ||= repo.commits.create!(payload.commit) if payload.commit
          end

          def store_config_info
            Travis::TravisYmlStats.store_stats(request)
          rescue => e
            Travis.logger.warn("[request:receive] Couldn't store .travis.yml stats: #{e.message}")
            Travis::Exceptions.handle(e)
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
