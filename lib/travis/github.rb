module Travis
  module Github
    autoload :Services, 'travis/github/services'

    class << self
      def authenticated(user, &block)
        fail "we don't have a github token for #{user.inspect}" if user.github_oauth_token.blank?
        GH.with(:token => user.github_oauth_token, &block)
      end

      # TODO: Maybe this should move to gh?
      def scopes_for(token)
        token  = token.github_oauth_token if token.respond_to? :github_oauth_token
        scopes = GH.with(token: token.to_s) { GH.head('user') }.headers['x-oauth-scopes'] if token.present?
        scopes &&= scopes.gsub(/\s/,'').split(',')
        Array(scopes).sort
      rescue GH::Error
        []
      end
    end
  end
end
