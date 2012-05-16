# Helper object that is aggregated by a Repository and allows to de/activate
# a service hook on Github.
class ServiceHook
  ATTRIBUTES = [:owner_name, :name, :description, :url, :active, :repository]

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
      data = {
        :token  => user.tokens.first.token,
        :user   => user.login
      }
      data[:domain] = Travis.config.service_hook_url if Travis.config.service_hook_url

      Travis::Github::ServiceHook.add(owner_name, name, user.github_oauth_token, data)
    end

    def deactivate(user)
      Travis::Github::ServiceHook.remove(owner_name, name, user.github_oauth_token)
    end
end

