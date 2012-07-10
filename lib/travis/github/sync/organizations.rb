require 'gh'

module Travis
  module Github
    module Sync
      class Organizations
        extend Travis::Instrumentation

        attr_reader :user

        def initialize(user)
          @user = user
        end

        def run
          user.authenticated_on_github do
            fetch.map do |data|
              org = Organization.find_or_create_by_github_id(data['id'])
              org.update_attributes!(:name => data['name'], :login => data['login'])
              user.organizations << org unless user.organizations.include?(org)
              org
            end
          end
        end
        instrument :run

        private

          def fetch
            GH['user/orgs'].to_a
          end
          instrument :fetch, :level => :debug

        Travis::Notification::Instrument::Github::Sync::Organizations.attach_to(self)
      end
    end
  end
end
