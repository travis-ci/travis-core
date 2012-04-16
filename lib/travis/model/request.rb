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
  autoload :Factory,  'travis/model/request/factory'
  autoload :States,   'travis/model/request/states'

  include Approval, States

  class << self
    def create_from(type, data, token)
      ActiveSupport::Notifications.publish('github.requests', 'received', data)
      Factory.new(type, data, token).request
    end

    def last_by_head_commit(head_commit)
      where(:head_commit => head_commit).order(:id).last
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
      ActiveSupport::Notifications.publish('github.requests.accepted', payload)
      build_job(:repository => repository, :commit => commit, :owner => owner) # create the initial configure job
    else
      ActiveSupport::Notifications.publish('github.requests.rejected', payload)
      self.state = :finished
    end
  end

  def pull_request?
    event_type == 'pull_request'
  end

  def event_type
    unless attributes['event_type'].blank?
      attributes['event_type']
    else
      'push'
    end
  end
end
