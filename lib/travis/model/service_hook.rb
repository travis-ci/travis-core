require 'faraday/utils'

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
      user.authenticated_on_github do
        update('subscribe', :user => user.login, :token => user.tokens.first.token, :domain => domain)
      end
    end

    def deactivate(user)
      user.authenticated_on_github do
        update('unsubscribe')
      end
    end

    def update(action, params = {})
      data = { :'hub.mode' => action, :'hub.topic' => topic, :'hub.callback' => callback(params) }
      body = Faraday::Utils.build_nested_query(data)
      GH.post('hub', body)
    end

    def topic
      "https://github.com/#{owner_name}/#{name}/events/push"
    end

    def callback(params)
      callback = "github://travis"
      callback += '?' + params.map { |key, value| [key, value].join('=') }.join('&') unless params.empty?
      callback
    end

    def domain
      Travis.config.service_hook_url || ''
    end
end

