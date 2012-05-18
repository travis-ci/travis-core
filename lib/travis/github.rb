require 'octokit'

module Travis
  module Github
    autoload :Payload,     'travis/github/payload'
    autoload :ServiceHook, 'travis/github/service_hook'

    class ServiceHookError < StandardError; end

    class << self
      def repositories_for_user(user)
        user.authenticated_on_github do
          GH['user/repos?per_page=100']
        end
      end
    end
  end
end
