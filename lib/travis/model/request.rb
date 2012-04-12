require 'active_record'
require 'metriks'

# Models an incoming request. The only supported source for requests currently is Github.
#
# The Request will be configured by fetching `.travis.yml` from the Github API
# and needs to be approved based on the configuration. Once approved the
# Request creates a Build.
class Request < ActiveRecord::Base
  autoload :Approval, 'travis/model/request/approval'
  autoload :Branches, 'travis/model/request/branches'
  autoload :Payload,  'travis/model/request/payload'
  autoload :States,   'travis/model/request/states'

  include Approval, States

  class << self
    # TODO clean this up, maybe extract a factory?
    def create_from(type, data, token)
      ActiveSupport::Notifications.publish('github.requests', 'received', data)
      payload = Travis::Github::Payload.for(type, data)
      if payload.accept?
        owner = owner_for(payload.owner)
        repository = repository_for(payload.repository, owner)
        commit = commit_for(payload.commit, repository) if payload.commit
        repository.requests.create!(payload.request.merge(:state => :created, :commit => commit, :owner => owner, :token => token, :event_type => type))
      end
    end

    def owner_for(attrs)
      type = attrs[:type].constantize
      type.find_by_login(attrs[:login]) || type.create_from_github(attrs[:login])
    end

    def repository_for(attrs, owner)
      Repository.find_or_create_by_owner_name_and_name(owner.login, attrs[:name]).tap do |repo|
        repo.update_attributes! attrs.merge(:owner => owner)
      end
    end

    def commit_for(attrs, repository)
      Commit.create!(attrs.merge(:repository_id => repository.id))
    end
  end

  has_one    :job, :as => :source, :class_name => 'Job::Configure'
  belongs_to :commit
  belongs_to :repository
  belongs_to :owner, :polymorphic => true
  has_many   :builds

  validates :repository_id, :presence => true

  serialize :config

  before_create do
    if accept?
      ActiveSupport::Notifications.publish('github.requests', 'accepted', payload)
      build_job(:repository => repository, :commit => commit, :owner => owner) # create the initial configure job
    else
      ActiveSupport::Notifications.publish('github.requests', 'rejected', payload)
      self.state = :finished
    end
  end
end
