class User
  module Oauth
    class << self
      def wanted_scopes
        return [] unless Travis.config.oauth2.try(:scope)
        @wanted_scopes ||= Travis.config.oauth2.scope.split(',').sort
      end

      def find_or_create_by(payload)
        attrs = attributes_from(payload)
        user = User.find_by_github_id(attrs['github_id'])
        user ? user.update_attributes(attrs) : user = User.create!(attrs)
        user
      end

      def attributes_from(payload)
        {
          'name'               => payload['info']['name'],
          'email'              => payload['info']['email'],
          'login'              => payload['info']['nickname'],
          'github_id'          => payload['uid'].to_i,
          'github_oauth_token' => payload['credentials']['token'],
          'avatar_url'         => payload['extra']['raw_info']['avatar_url']
        }
      end
    end
  end
end
