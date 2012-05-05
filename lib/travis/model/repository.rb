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

  has_many :requests, :dependent => :delete_all
  has_many :builds, :dependent => :delete_all do
    def last_status_on(params)
      last_finished_on_branch(params[:branch]).try(:matrix_status, params)
    end
  end

  has_one :last_build,   :class_name => 'Build', :order => 'id DESC', :conditions => { :state  => ['started', 'finished']  }
  has_one :last_success, :class_name => 'Build', :order => 'id DESC', :conditions => { :status => 0 }
  has_one :last_failure, :class_name => 'Build', :order => 'id DESC', :conditions => { :status => 1 }
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

    def recent
      limit(25)
    end

    def by_owner_name(owner_name)
      where(:owner_name => owner_name)
    end

    def by_slug(slug)
      where(:owner_name => slug.split('/').first, :name => slug.split('/').last)
    end

    def search(query)
      query = query.gsub('\\', '/')
      where("(repositories.owner_name || chr(47) || repositories.name) ILIKE ?", "%#{query}%")
    end

    def find_by(params)
      if id = params[:repository_id] || params[:id]
        self.find(id)
      else
        self.where(params.slice(:name, :owner_name)).first || raise(ActiveRecord::RecordNotFound)
      end
    end

    def by_name
      Hash[*all.map { |repository| [repository.name, repository] }.flatten]
    end
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
    builds.descending.paged({}).includes([:commit]).map{ |build| build.commit.branch }.uniq
  end

  def last_build_status(params = {})
    params = params.symbolize_keys.slice(*Build.matrix_keys_for(params))
    params.blank? ? read_attribute(:last_build_status) : builds.last_status_on(params)
  end

  def last_finished_builds_by_branches
    n = branches.map { |branch| builds.last_finished_on_branch(branch) }.compact
    n.sort { |a, b| b.finished_at <=> a.finished_at }
  end

  def rails_fork?
    slug != 'rails/rails' && slug =~ %r(/rails$)
  end
end
