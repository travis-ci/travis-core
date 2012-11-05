# Helper object that is aggregated by a Repository and allows to de/activate
# a service hook on Github.
class ServiceHook
  EVENTS = [:push, :pull_request, :issue_comment, :public, :member]
  attr_accessor :id, :uid, :owner_name, :name, :description, :url, :active, :repository, :private, :user

  def initialize(attrs = {})
    attrs.each { |k,v| public_send("#{k}=", v) if respond_to?("#{k}=") }
  end

  def activate(user = nil)
    set(true, user)
  end

  def deactivate(user = nil)
    set(false, user)
  end

  def set(active, user = nil)
    self.active, self.user = active, user
    Travis::Services::Github.authenticated(self.user) { update } # TODO
    repository.update_column(:active, active)
  ensure
    self.active = repository.active
  end

  def repository
    @repository ||= Repository.where(:owner_name => owner_name, :name => name).first
  end

  def user
    @user || repository.admin
  end

  private

    def hook
      @hook ||= find || create
    end

    def update
      GH.patch(hook_url, payload) unless hook['active'] == active
    end

    def find
      GH[hooks_url].detect { |hook| hook['name'] == 'travis' && hook['config']['domain'] == domain }
    end

    def create
      GH.post(hooks_url, payload)
    end

    def payload
      {
        :name   => 'travis',
        :events => EVENTS,
        :active => active,
        :config => { :user => user.login, :token => user.tokens.first.token, :domain => domain }
      }
    end

    def hooks_url
      "repos/#{repository.slug}/hooks"
    end

    def hook_url
      hook['_links']['self']['href']
    end

    def domain
      Travis.config.service_hook_url || ''
    end
end
