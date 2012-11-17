require 'active_record'
require 'gh'

class User < ActiveRecord::Base
  autoload :Oauth, 'travis/model/user/oauth'

  has_many :tokens
  has_many :memberships
  has_many :organizations, :through => :memberships
  has_many :permissions
  has_many :repositories, :through => :permissions

  attr_accessible :name, :login, :email, :github_id, :github_oauth_token, :gravatar_id, :locale

  before_create :set_as_recent
  after_create :create_a_token

  class << self
    def with_permissions(permissions)
      where(:permissions => permissions).includes(:permissions)
    end

    def authenticate_by(options)
      options = options.symbolize_keys
      includes(:tokens).where(:login => options[:login], 'tokens.token' => options[:token]).first
    end

    def find_or_create_for_oauth(payload)
      Oauth.find_or_create_by(payload)
    end
  end

  def permission?(roles, options = {})
    !!permissions.by_roles(roles).where(options).first
  end

  def first_sync?
    synced_at.nil?
  end

  def sync
    Travis::Services.run_service(:sync_user, self) # TODO remove once apps use the service
  end

  def syncing?
    is_syncing?
  end

  def service_hook(options = {})
    service_hooks(options).first
  end

  def service_hooks(options = {})
    hooks = repositories.administratable.order('owner_name, name')
    # TODO remove owner_name/name once we're on api everywhere
    if options.key?(:id)
      hooks = hooks.where(options.slice(:id))
    elsif options.key?(:owner_name) || options.key?(:name)
      hooks = hooks.where(options.slice(:id, :owner_name, :name))
    end
    hooks
  end

  def organization_ids
    @organization_ids ||= memberships.map(&:organization_id)
  end

  def repository_ids
    @repository_ids ||= permissions.map(&:repository_id)
  end

  def recently_signed_up?
    @recently_signed_up || false
  end

  def profile_image_hash
    # TODO:
    #   If Github always sends valid gravatar_id in oauth payload (need to check that)
    #   then these fallbacks (email hash and zeros) are superfluous and can be removed.
    gravatar_id.presence || (email? && Digest::MD5.hexdigest(email)) || '0' * 32
  end

  def authenticated_on_github(&block)
    Travis::Services::Github.authenticated(self, &block) # TODO
  end

  protected

    def set_as_recent
      @recently_signed_up = true
    end

    def create_a_token
      self.tokens.create!
    end
end
