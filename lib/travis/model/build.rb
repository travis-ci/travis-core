require 'active_record'
require 'core_ext/active_record/base'
require 'core_ext/hash/deep_symbolize_keys'

# Build currently models a central but rather abstract domain entity: the thing
# that is triggered by a Github request (service hook ping).
#
# Build groups a matrix of Job::Test instances, and belongs to a Request (and
# thus Commit as well as a Repository).
#
# A Build is created when its Request was configured (by fetching .travis.yml)
# and approved (e.g. not excluded by the configuration). Once a Build is
# created it will expand its matrix according to the given configuration and
# create the according Job::Test instances.  Each Job::Test instance will
# trigger a test run remotely (on the worker). Once all Job::Test instances
# have finished the Build will be finished as well.
#
# Each of these state changes (build:created, job:started, job:finished, ...)
# will issue events that are listened for by the event handlers contained in
# travis/notification. These event handlers then send out various notifications
# of various types through email, pusher and irc, archive builds and queue
# jobs for the workers.
#
# Build is split up to several modules:
#
#  * Build         - ActiveRecord structure, validations and scopes
#  * States        - state definitions and events
#  * Denormalize   - some state changes denormalize attributes to the build's
#                    repository (e.g. Build#started_at gets propagated to
#                    Repository#last_started_at)
#  * Matrix        - logic related to expanding the build matrix, normalizing
#                    configuration for Job::Test instances, evaluating the
#                    final build result etc.
#  * Messages      - helpers for evaluating human readable status messages
#                    (e.g. "Still Failing")
#  * Notifications - helpers that are used by notification handlers (and that
#                    TODO probably should be cleaned up and moved to
#                    travis/notification)
class Build < ActiveRecord::Base
  autoload :Denormalize,   'travis/model/build/denormalize'
  autoload :Matrix,        'travis/model/build/matrix'
  autoload :Messages,      'travis/model/build/messages'
  autoload :Notifications, 'travis/model/build/notifications'
  autoload :States,        'travis/model/build/states'

  include Matrix, States, Messages

  belongs_to :commit
  belongs_to :request
  belongs_to :repository, :autosave => true
  has_many   :matrix, :as => :owner, :order => :id, :class_name => 'Job::Test', :dependent => :destroy

  validates :repository_id, :commit_id, :request_id, :presence => true

  serialize :config

  class << self
    def recent(options = {})
      was_started.descending.paged(options).includes([:commit, { :matrix => :commit }])
    end

    def was_started
      where(:state => ['started', 'finished'])
    end

    def finished
      where(:state => 'finished')
    end

    def on_branch(branches)
      branches = normalize_to_array(branches)
      joins(:commit).where(branches.present? ? ["commits.branch IN (?)", branches] : [])
    end

    def previous(build)
      where("builds.repository_id = ? AND builds.id < ?", build.repository_id, build.id).finished.descending.limit(1).first
    end

    def last_finished_on_branch(branches)
      finished.on_branch(branches).descending.first
    end

    def descending
      order(arel_table[:id].desc)
    end

    def paged(options)
      page = (options[:page] || 1).to_i
      limit(per_page).offset(per_page * (page - 1))
    end

    def older_than(build = nil)
      criteria = if build
        number = build.is_a?(Build) ? build.number : build
        where('number::integer < ?', number.to_i)
      else
        Build
      end
      criteria.includes(:commit).order('number::int DESC').limit(per_page)
    end

    def next_number
      maximum(floor('number')).to_i + 1
    end

    protected

      def normalize_to_array(object)
        Array(object).compact.join(',').split(',')
      end

      def per_page
        25
      end
  end

  after_initialize do
    self.config = {} if config.nil?
  end

  # set the build number and expand the matrix
  before_create do
    self.number = repository.builds.next_number
    expand_matrix
  end

  # sometimes the config is not deserialized and is returned
  # as a string, this is a work around for now :(
  def config
    deserialized = self['config']
    if deserialized.is_a?(String)
      logger.warn "Attribute config isn't YAML. Current serialized attributes: #{Build.serialized_attributes}"
      deserialized = YAML.load(deserialized)
    end
    deserialized
  end

  def previous_on_branch
    Build.on_branch(commit.branch).previous(self)
  end

  def config=(config)
    super(config.deep_symbolize_keys)
  end
end
