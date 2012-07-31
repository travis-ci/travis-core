# Helper object that is aggregated by a Repository and allows to de/activate
# a service hook on Github.
class ServiceHook
  ATTRS = [:uid, :owner_name, :name, :description, :url, :active, :repository, :private]

  attr_accessor *ATTRS

  def initialize(attrs)
    ATTRS.each { |name| self.send(:"#{name}=", attrs[name]) if attrs.key?(name) }
  end

  def set(active, user)
    active ? activate(user) : deactivate(user)
    repository.update_column(:active, active)
  end

  def repository
    @repository ||= Repository.where(:owner_name => owner_name, :name => name).first
  end

  protected

    def activate(user)
      authenticated(user) do
        update('subscribe', :user => user.login, :token => user.tokens.first.token, :domain => domain)
      end
    end

    def deactivate(user)
      authenticated(user) do
        update('unsubscribe')
      end
    end

    def update(action, params = {})
      data = { :'hub.mode' => action, :'hub.topic' => topic, :'hub.callback' => callback(params) }

      # GH.post('hub', data)
      connection = Faraday.new(:url => 'https://api.github.com') do |builder|
        builder.request(:authorization, :token, token)
        builder.request :multipart
        builder.request :url_encoded
        builder.adapter :net_http
      end
      connection.post('/hub', data)
    end

    def authenticated(user, &block)
      # user.authenticated_on_github(&block)
      @token = user.github_oauth_token
      yield
    end
    attr_reader :token

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

