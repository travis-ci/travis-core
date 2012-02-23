require 'active_record'
require 'metriks'

# Models an incoming request. The only supported source for requests currently is Github.
#
# The Request will be configured by fetching `.travis.yml` from the Github API
# and needs to be approved based on the configuration. Once approved the
# Request creates a Build.
class Request < ActiveRecord::Base
  autoload :Branches, 'travis/model/request/branches'
  autoload :Payload,  'travis/model/request/payload'
  autoload :States,   'travis/model/request/states'

  include States

  class << self
    # TODO clean this up
    def create_from(payload, token)
      Metriks.counter("github:requests").increment
      payload = Payload::Github.new(payload, token)
      unless payload.reject?
        Metriks.counter("github:requests:accepted").increment
        repository = repository_for(payload.repository)
        commit = commit_for(payload, repository)
        repository.requests.create!(payload.attributes.merge(:state => :created, :commit => commit))
      end
    end

    def repository_for(payload)
      Repository.find_or_create_by_owner_name_and_name(payload.owner_name, payload.name).tap do |repository|
        repository.update_attributes!(payload.to_hash)
      end
    end

    def commit_for(payload, repository)
      Commit.create!(payload.attributes[:commit].merge(:repository_id => repository.id))
    end
  end

  has_one    :job, :as => :owner, :class_name => 'Job::Configure'
  belongs_to :commit
  belongs_to :repository
  has_many   :builds

  validates :repository_id, :commit_id, :presence => true

  serialize :config

  before_create do
    # create the initial configure job
    build_job(:repository => repository, :commit => commit)
  end
end
