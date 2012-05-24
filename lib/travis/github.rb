require 'gh'

module Travis
  module Github
    autoload :Payload,      'travis/github/payload'
    autoload :Repositories, 'travis/github/repositories'

    class << self
      def repositories_for(user)
        Repositories.new(user).fetch
      end
    end
  end
end
