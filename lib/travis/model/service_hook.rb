require 'travis/github_api'

# Helper object that is aggregated by a Repository and allows to de/activate
# a service hook on Github.
class ServiceHook
  ATTRIBUTES = [:uid, :owner_name, :name, :description, :url, :active, :repository]

  attr_accessor *ATTRIBUTES

  def initialize(attrs)
    ATTRIBUTES.each { |name| self.send(:"#{name}=", attrs[name]) if attrs.key?(name) }
  end

  def set(active, user)
    active ? activate(user) : deactivate(user)
    repository.update_attribute(:active, active)
  end

  def repository
    @repository ||= Repository.where(:owner_name => owner_name, :name => name).first
  end

  protected

    def activate(user)
      Travis::GithubApi.add_service_hook(owner_name, name, user.github_oauth_token,
        :token  => user.tokens.first.token,
        :user   => user.login,
        :domain => Travis.config.domain
      )
    end

    def deactivate(user)
      Travis::GithubApi.remove_service_hook(owner_name, name, user.github_oauth_token)
    end
end

