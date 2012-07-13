require 'active_support/core_ext/class/attribute'

module Travis
  module Github
    module Sync
      class Repositories
        extend Travis::Instrumentation

        class_attribute :type
        self.type = 'public'

        class << self
          def private?
            self.type == 'private'
          end
        end

        attr_reader :user, :resources, :data

        def initialize(user)
          @user = user
          @resources = ['user/repos'] + user.organizations.map { |org| "orgs/#{org.login}/repos" }
        end

        def run
          with_github do
            @data = fetch
            filter(data).map do |repository|
              Repository.new(user, repository).run
            end
          end
        end
        instrument :run

        private

          def fetch
            resources.map { |resource| fetch_resource(resource) }.map(&:to_a).flatten.compact
          end
          instrument :fetch, :level => :debug

          # we have to filter these ourselves because the github api is broken for this
          def filter(repos)
            repos.select { |repo| repo['private'] == self.class.private? }
          end

          def fetch_resource(resource)
            GH[resource] # should be: ?type=#{self.class.type}
          rescue Faraday::Error::ResourceNotFound => e
            log_exception(e)
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

          Travis::Notification::Instrument::Github::Sync::Repositories.attach_to(self)
      end
    end
  end
end



