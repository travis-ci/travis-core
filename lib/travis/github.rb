module Travis
  module Github
    autoload :Payload, 'travis/github/payload'

    class << self
      def repositories_for(user)
        user.authenticated_on_github do
          GH['user/repos?per_page=100']
        end
      end
    end
  end
end
