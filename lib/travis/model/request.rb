require 'active_record'

class Request < ActiveRecord::Base
  autoload :Branches, 'travis/model/request/branches'
  autoload :Payload,  'travis/model/request/payload'
  autoload :States,   'travis/model/request/states'

  include States

  class << self
    # TODO replace with registration API?
    def payload_class_for(type)
      case type
      when 'push'         then Payload::Github::Push
      when 'pull_request' then Payload::Github::PullRequest
      else raise ArgumentError, "unsupported github event"
      end
    end

    # TODO clean this up
    def create_from(type, payload, token)
      payload = payload_class_for(type).new(payload, token)
      unless payload.reject?
        repository = repository_for(payload.repository)
        commit = commit_for(payload, repository)
        repository.requests.create!(payload.attributes.merge(:state => :created, :commit => commit, :event_type => type))
      end
    end

    def repository_for(repository)
      owner = repository.owner
      Repository.find_or_create_by_owner_name_and_name(owner.login, repository.name).tap do |repository|
        repository.update_attributes! :owner_email => owner.email, :description => repository.description
      end
    end

    def commit_for(payload, repository)
      Commit.create!(payload.attributes[:commit].merge(:repository_id => repository.id))
    end
  end

  has_one    :job, :as => :owner, :class_name => 'Job::Configure'
  belongs_to :commit
  belongs_to :repository
  belongs_to :head_repository
  belongs_to :head_commit
  has_many   :builds

  validates :repository_id, :commit_id, :presence => true

  serialize :config

  before_create do
    build_job(:repository => repository, :commit => commit)
  end

  def create_build!
    build = builds.create!(:repository => repository, :commit => commit, :config => config)
  end
end
