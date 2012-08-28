require 'gh'

module Travis
  module Github
    autoload :Admin,   'travis/github/admin'
    autoload :Config,  'travis/github/config'
    autoload :Payload, 'travis/github/payload'
    autoload :Sync,    'travis/github/sync'

    class << self
      def authenticated(user, &block)
        fail "we don't have a github token for #{user.inspect}" if user.github_oauth_token.blank?
        GH.with(:token => user.github_oauth_token, &block)
      end

      def repositories_for(user)
        Repositories.new(user).fetch
      end

      def create_user(login)
        data = GH["users/#{login}"] || raise(Travis::GithubApiError)
        User.create!(:name => data['name'], :login => data['login'], :email => data['email'], :github_id => data['id'], :gravatar_id => data['gravatar_id'])
      end

      def create_organization(login)
        data = GH["orgs/#{login}"] || raise(Travis::GithubApiError)
        Organization.create!(:name => data['name'], :login => data['login'], :github_id => data['id'])
      end
    end
  end
end
