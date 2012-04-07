require 'active_record'
require 'devise'
require 'devise/orm/active_record'
require 'gh'

class User < ActiveRecord::Base
  devise :omniauthable

  has_many :tokens
  has_many :memberships
  has_many :organizations, :through => :memberships

  attr_accessible :name, :login, :email, :github_id, :github_oauth_token, :gravatar_id

  before_create :set_as_recent
  after_create :create_a_token

  class << self
    def create_from_github(name)
      # TODO ask @rkh about this
      data = GH["users/#{name}"] || raise(Travis::GithubApiError)
      create!(:name => data['name'], :login => data['login'], :email => data['email'], :github_id => data['id'], :gravatar_id => data['gravatar_id'])
    end

    def find_or_create_for_oauth(payload)
      data = user_data_from_oauth(payload)
      user = User.find_by_github_id(data['github_id'])
      user ? user.update_attributes(data) : user = create!(data)
      user
    end

    def user_data_from_oauth(payload) # TODO move this to a OauthPayload
      {
          'name'               => payload['info']['name'],
          'email'              => payload['info']['email'],
          'login'              => payload['info']['nickname'],
          'github_id'          => payload['uid'].to_i,
          'github_oauth_token' => payload['credentials']['token'],
          'gravatar_id'        => payload['extra']['raw_info']['gravatar_id']
      }
    end
  end

  def organization_ids
    @organization_ids ||= memberships.map(&:organization_id)
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

  def github_service_hooks
    Travis::GithubApi.repositories_for_user(login).map do |data|
      ServiceHook.new(
        :uid => [data.owner.login, data.name].join(':'),
        :owner_name => data.owner.login,
        :name => data.name,
        :url => data.html_url,
        :active => repositories[data.name] && repositories[data.name].active,
        :description => data.description
      )
    end
  end

  # TODO: We don't use the GH library yet (used in pull-requests branch)
  def authenticated_on_github(&block)
    fail "we don't have a github token for #{inspect}" if github_oauth_token.blank?
    GH.with(:token => github_oauth_token, &block)
  end

  protected

    def set_as_recent
      @recently_signed_up = true
    end

    def create_a_token
      self.tokens.create!
    end

    def repositories
      @repositories ||= Repository.where(:owner_name => login).by_name
    end
end
