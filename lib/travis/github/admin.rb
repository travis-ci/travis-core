require 'faraday/error'

module Travis
  module Github
    class Admin
      extend Travis::Instrumentation
      include Travis::Logging

      class << self
        def for_repository(repository)
          new(repository).find
        end
      end

      attr_reader :repository

      def initialize(repository)
        @repository = repository
      end

      def find
        admin = candidates.detect { |user| validate(user) }
        admin || raise_admin_missing
      end
      instrument :find

      private

        def candidates
          User.with_permissions(:repository_id => repository.id, :admin => true)
        end

        def validate(user)
          data = Github.authenticated(user) { repository_data }
          if data['permissions'] && data['permissions']['admin']
            user
          else
            update(user, data['permissions'])
            false
          end
        rescue Faraday::Error::ClientError => e
          error "[github-admin] error retrieving repository info for #{repository.slug} for #{user.login}: #{e.inspect}"
          false
        end

        def repository_data
          data = GH["repos/#{repository.slug}"]
          info "[github-admin] could not retrieve data for #{repository.slug}" unless data
          data || { 'permissions' => {} }
        end

        def update(user, permissions)
          user.update_attributes!(:permissions => permissions)
        end

        def raise_admin_missing
          raise Travis::AdminMissing.new("no admin available for #{repository.slug}")
        end


        Travis::Notification::Instrument::Github::Admin.attach_to(self)
    end
  end
end
