require 'gh'

module Travis
  module Github
    autoload :Config,       'travis/github/config'
    autoload :Payload,      'travis/github/payload'
    autoload :Repositories, 'travis/github/repositories'
    autoload :Sync,         'travis/github/sync'

    class << self
      def repositories_for(user)
        Repositories.new(user).fetch
      end
    end
  end
end
