require 'active_support/core_ext/class/attribute'

module Travis
  module Github
    class Repositories
      class_attribute :type
      self.type = 'public'

      attr_accessor :user

      def initialize(user)
        @user = user
      end

      def fetch
        authenticated do
          resources_for(user).map do |resource|
            GH["#{resource}?type=#{self.class.type}"].to_a
          end.flatten
        end
      end

      private

        def authenticated(&block)
          GH.with(:token => user.github_oauth_token, &block)
        end

        def resources_for(user)
          ['user/repos'] + user.organizations.map { |org| "orgs/#{org.login}/repos" }
        end
    end
  end
end

