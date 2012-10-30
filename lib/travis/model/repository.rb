require 'uri'
require 'core_ext/hash/compact'
require 'active_record'

# Models a repository that has many builds and requests.
#
# A repository has an ssl key pair that is used to encrypt and decrypt
# sensitive data contained in the public `.travis.yml` file, such as Campfire
# authentication data.
#
# A repository also has a ServiceHook that can be used to de/activate service
# hooks on Github.
class Repository < ActiveRecord::Base
  autoload :Compat, 'travis/model/repository/compat'

  include Compat

  has_many :commits, :dependent => :delete_all
  has_many :requests, :dependent => :delete_all
  has_many :builds, :dependent => :delete_all
  has_many :events
  has_many :permissions
  has_many :users, :through => :permissions

  has_one :last_build,   :class_name => 'Build', :order => 'id DESC', :conditions => { :state  => ['started', 'finished']  }
  has_one :last_success, :class_name => 'Build', :order => 'id DESC', :conditions => { :result => 0 }
  has_one :last_failure, :class_name => 'Build', :order => 'id DESC', :conditions => { :result => 1 }
  has_one :key, :class_name => 'SslKey'
  belongs_to :owner, :polymorphic => true

  validates :name,       :presence => true, :uniqueness => { :scope => :owner_name }
  validates :owner_name, :presence => true

  before_create do
    build_key
  end

  delegate :public_key, :to => :key

  class << self
    def timeline
      where(arel_table[:last_build_started_at].not_eq(nil)).order(arel_table[:last_build_started_at].desc)
    end

    def administratable
      includes(:permissions).where('permissions.admin = ?', true)
    end

    def recent
      limit(25)
    end

    def by_owner_name(owner_name)
      where(:owner_name => owner_name)
    end

    def by_member(login)
      joins(:users).where(:users => { :login => login })
    end

    def by_slug(slug)
      where(:owner_name => slug.split('/').first, :name => slug.split('/').last)
    end

    def search(query)
      query = query.gsub('\\', '/')
      where("(repositories.owner_name || chr(47) || repositories.name) ILIKE ?", "%#{query}%")
    end

    def active
      where(:active => true)
    end

    def find_by(params)
      if id = params[:repository_id] || params[:id]
        find_by_id(id)
      elsif params.key?(:slug)
        by_slug(params[:slug]).first
      elsif params.key?(:name) && params.key?(:owner_name)
        where(params.slice(:name, :owner_name)).first
      end
    end

    def by_name
      Hash[*all.map { |repository| [repository.name, repository] }.flatten]
    end

    def counts_by_owner_names(owner_names)
      query = %(SELECT owner_name, count(*) FROM repositories WHERE owner_name IN (?) GROUP BY owner_name)
      query = sanitize_sql([query, owner_names])
      rows = connection.select_all(query, owner_names)
      Hash[*rows.map { |row| [row['owner_name'], row['count'].to_i] }.flatten]
    end
  end

  def admin
    @admin ||= Travis::Services::Github::FindAdmin.for_repository(self)
  end

  def slug
    @slug ||= [owner_name, name].join('/')
  end

  def source_url
    private? ? "git@github.com:#{slug}.git": "git://github.com/#{slug}.git"
  end

  def service_hook
    @service_hook ||= ::ServiceHook.new(
      :owner_name => owner_name,
      :name => name,
      :active => active,
      :repository => self
    )
  end

  def branches
    self.class.connection.select_values %(
      SELECT DISTINCT ON (branch) branch
      FROM   builds
      JOIN   commits ON builds.commit_id = commits.id
      WHERE  builds.repository_id = #{id}
      ORDER  BY branch DESC
      LIMIT  25
    )
  end

  def last_build_result(params = {})
    if params.blank?
      read_attribute(:last_build_result)
    else
      puts '[DEPRECATED] last_build_results with params is deprecated. please use last_build_result_on(params)'
      last_build_result_on(params)
    end
  end

  def last_build_result_on(params)
    params = params.symbolize_keys.slice(*Build.matrix_keys_for(params)).compact
    params.empty? ? last_build_result || last_build.try(:previous_result) : builds.last_result_on(params[:branch], params.slice(*Build::Matrix::ENV_KEYS))
  end

  def last_finished_builds_by_branches
    builds.where(:id => last_finished_builds_by_branches_ids).order(:finished_at)
  end

  def last_finished_builds_by_branches_ids
    self.class.connection.select_values %(
      SELECT DISTINCT ON (branch) builds.id
      FROM   builds
      JOIN   commits ON builds.commit_id = commits.id
      WHERE  builds.repository_id = #{id}
      ORDER  BY branch, finished_at DESC
      LIMIT  25
    )
  end
end
