require 'gh'

module Travis
  module Github
    autoload :Payload, 'travis/github/payload'

    class << self
      def repositories_for(user)
        GH.with(:token => user.github_oauth_token) do
          resources_for(user).map do |resource|
            GH["#{resource}?per_page=100"]
          end.flatten
        end
      end

      private

        def resources_for(user)
          ['user/repos'] + user.organizations.map { |org| "orgs/#{org.login}/repos" }
        end
    end
  end
end
