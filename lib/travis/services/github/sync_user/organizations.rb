require 'gh'

module Travis
  module Services
    module Github
      class SyncUser
        class Organizations
          class << self
            def cancel_memberships(user, orgs)
              user.memberships.where(:organization_id => orgs.map(&:id)).delete_all
            end
          end

          extend Travis::Instrumentation

          attr_reader :user, :data

          def initialize(user)
            @user = user
          end

          def run
            with_github do
              { :synced => create_or_update, :removed => remove }
            end
          end
          instrument :run

          private

            def create_or_update
              fetch.map do |data|
                org = Organization.find_or_create_by_github_id(data['id'])
                org.update_attributes!(:name => data['name'], :login => data['login'])
                user.organizations << org unless user.organizations.include?(org)
                org
              end
            end

            def remove
              orgs = user.organizations.reject { |org| github_ids.include?(org.github_id) }
              self.class.cancel_memberships(user, orgs)
              orgs
            end

            def fetch
              @data ||= GH['user/orgs'].to_a
            end
            instrument :fetch, :level => :debug

            def github_ids
              @github_ids ||= data.map { |org| org['id'] }
            end

            def with_github(&block)
              # TODO in_parallel should return the block's result in a future version
              result = nil
              GH.with(:token => user.github_oauth_token) do
                # GH.in_parallel do
                  result = yield
                # end
              end
              result
            end

            Travis::Notification::Instrument::Services::Github::SyncUser::Organizations.attach_to(self)
        end
      end
    end
  end
end
