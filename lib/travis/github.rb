require 'gh'

module Travis
  module Github
    autoload :Admin,   'travis/github/admin'
    autoload :Config,  'travis/github/config'
    autoload :Payload, 'travis/github/payload'
    autoload :Sync,    'travis/github/sync'

    class << self
      def setup(config = Travis.config.oauth2)
        GH.set :client_id => config[:client_id], :client_secret => config[:client_secret] if config
      end

      def authenticated(user, &block)
        fail "we don't have a github token for #{user.inspect}" if user.github_oauth_token.blank?
        GH.with(:token => user.github_oauth_token, &block)
      end
    end

    setup
  end
end
