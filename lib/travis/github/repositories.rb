require 'active_support/core_ext/class/attribute'

module Travis
  module Github
    # encapsulates fetching repositories for a given user
    class Repositories
      include Logging
      extend Instrumentation

      class_attribute :type
      self.type = 'public'

      class << self
        def private?
          self.type == 'private'
        end
      end

      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def fetch
        with_github { filter(data) }
      end
      instrument :fetch, :level => :debug # TODO add debug level (e.g. exclude metrics)

      def resources
        ['user/repos'] + user.organizations.map { |org| "orgs/#{org.login}/repos" }
      end

      def data
        @data ||= resources.map { |resource| fetch_resource(resource) }.map(&:to_a).flatten.compact
      end

      private

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

        def fetch_resource(resource)
          GH[resource] # should be: ?type=#{self.class.type}
        rescue Faraday::Error::ResourceNotFound => e
          log_exception(e)
        end

        # we have to filter these ourselves because the github api is broken for this
        def filter(repos)
          repos.select { |repo| repo['private'] == self.class.private? }
        end

        Notification::Instrument::Github::Repositories.attach_to(self)
    end
  end
end

