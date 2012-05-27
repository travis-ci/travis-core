require 'active_support/core_ext/class/attribute'

module Travis
  module Github
    class Repositories
      include Logging

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
        authenticated do
          repos = resources_for(user).map do |resource|
            fetch_resource(resource)
          end.flatten.compact
          filter(repos.flatten)
        end
      end

      private

        def authenticated(&block)
          GH.with(:token => user.github_oauth_token, &block)
        end

        def fetch_resource(resource)
          GH["#{resource}"].to_a # should be: ?type=#{self.class.type}
        rescue Faraday::Error::ResourceNotFound => e
          log_exception(e)
        end

        def resources_for(user)
          ['user/repos'] + user.organizations.map { |org| "orgs/#{org.login}/repos" }
        end

        # we have to filter these ourselves because the github api is broken for this
        def filter(repos)
          repos.select { |repo| repo['private'] == self.class.private? }
        end
    end
  end
end
