require 'gh'

class Organization
  class Sync
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def run
      user.authenticated_on_github do
        GH['user/orgs'].each do |data|
          org = Organization.find_or_create_by_github_id(data['id'])
          org.update_attributes!(:name => data['name'], :login => data['login'])
          user.organizations << org unless user.organizations.include?(org)
        end
      end
    end
  end
end
