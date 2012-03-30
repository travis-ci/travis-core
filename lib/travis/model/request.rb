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
    def create_from(payload, token)
      ActiveSupport::Notifications.publish('github.requests', 'received', payload)
      payload = Payload::Github.new(payload, token)
      owner = owner_for(payload.repository)
      repository = repository_for(payload.repository, owner)
      commit = commit_for(payload, repository)
      repository.requests.create!(payload.attributes.merge(:state => :created, :commit => commit, :owner => owner))
    end

    def repository_for(payload, owner)
      Repository.find_or_create_by_owner_name_and_name(payload.owner_name, payload.name).tap do |repository|
        repository.update_attributes!(payload.to_hash.merge(:owner => owner))
      end
    end

    def commit_for(payload, repository)
      Commit.create!(payload.attributes[:commit].merge(:repository_id => repository.id)) if payload.attributes[:commit]
    end

    def owner_for(payload)
      type = payload.owner_type.constantize
      type.find_by_login(payload.owner_name) || type.create_from_github(payload.owner_name)
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
