class Request
  class Factory
    extend Travis::Instrumentation

    attr_reader :type, :data, :token

    def initialize(type, data, token)
      @type = (type || 'push').gsub('-', '_')
      @data = data
      @token = token
    end

    def request
      if accept?
        data = payload.request
        data.merge!(:state => :created, :commit => commit, :owner => owner, :token => token, :event_type => type)
        repository.requests.create!(data)
      end
    end
    instrument :request

    def accept?
      payload.accept?
    end

    private

      def payload
        @payload ||= Travis::Github::Payload.for(type, data)
      end

      def owner
        @owner ||= begin
          data = payload.owner
          type = data[:type].constantize
          type.find_by_login(data[:login]) || type.create_from_github(data[:login])
        end
      end

      def repository
        @repository ||= begin
          data = payload.repository
          Repository.find_or_create_by_owner_name_and_name(owner.login, data[:name]).tap do |repo|
            repo.update_attributes! data.merge(:owner => owner)
          end
        end
      end

      def commit
        @commit ||= if data = payload.commit
          Commit.create!(data.merge(:repository_id => repository.id))
        end
      end

      Travis::Notification::Instrument::Request::Factory.attach_to(self)
  end
end
