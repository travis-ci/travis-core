class Organization < ActiveRecord::Base
  class << self
    def create_from_github(name)
      # TODO ask @rkh about this
      data = GH["orgs/#{name}"] || raise(Travis::GithubApiError)
      create!(:name => data['name'], :login => data['login'], :github_id => data['id'])
    end

    def sync_for(user)
      user.authenticated_on_github do
        # TODO ask @rkh about this
        GH['user/orgs'].each do |data|
          org = Organization.find_or_create_by_github_id(data['id'])
          org.update_attributes!(:name => data['name'], :login => data['login'])
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

