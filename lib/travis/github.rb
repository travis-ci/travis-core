require 'octokit'

module Travis
  module Github
    autoload :Payload,     'travis/github/payload'
    autoload :ServiceHook, 'travis/github/service_hook'

    class ServiceHookError < StandardError; end

    class << self
      # TODO use GH
      def repositories_for_user(login)
        Octokit.repositories(login, :per_page => 9999)
      end
    end
  end
end
