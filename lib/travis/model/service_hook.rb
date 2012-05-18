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
      update(user, :token => user.tokens.first.token, :user => user.login, :domain => domain, :active => true)
    end

    def deactivate(user)
      update(user, :token => '', :user => '', :domain => '', :active => false)
    end

    def update(user, data)
      user.authenticated_on_github do
        GH.post("repos/#{repository.slug}/hooks", data)
      end
    end

    def domain
      Travis.config.service_hook_url || ''
    end
end

