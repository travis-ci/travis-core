# Helper object that is aggregated by a Repository and allows to de/activate
# a service hook on Github.
class ServiceHook
  EVENTS = [:push, :pull_request, :issue_comment, :public, :member]
  attr_accessor :uid, :owner_name, :name, :description, :url, :active, :repository, :private, :user

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
    Travis::Github.authenticated(self.user) { update }
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

    def update
      create unless hook
      GH.patch(hook_url, payload) unless hook['active'] == active
    end

    def hook
      @hook ||= GH[hooks].detect do |hook|
        hook["name"] == "travis" and hook['config']['domain'] == domain
      end
    end

    def payload
      {
        :name   => 'travis',
        :events => EVENTS,
        :active => active,
        :config => { :user => user.login, :token => user.tokens.first.token, :domain => domain }
      }
    end

    def create
      @hook = GH.post(hooks, payload)
    end

    def hooks
      "repos/#{repository.slug}/hooks"
    end

    def hook_url
      hook['_links']['self']['href']
    end

    def domain
      Travis.config.service_hook_url || ''
    end
end