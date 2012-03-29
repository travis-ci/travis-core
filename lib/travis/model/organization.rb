class Organization < ActiveRecord::Base
  class << self
    def sync_for(user)
      user.authenticated_on_github do
        # TODO
        GH['user/orgs'].each do |data|
          org = Organization.find_or_create_by_github_id(data['id'])
          org.update_attributes!(:login => data['login'])
          user.organizations << org unless user.organizations.include?(org)
        end
      end
    end
  end

  has_many :memberships
  has_many :users, :through => :memberships

  def github_oauth_token
    users.first.try(:github_oauth_token)
  end
end

