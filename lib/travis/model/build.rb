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
#  * Build       - ActiveRecord structure, validations and scopes
#  * States      - state definitions and events
#  * Denormalize - some state changes denormalize attributes to the build's
#                  repository (e.g. Build#started_at gets propagated to
#                  Repository#last_started_at)
#  * Matrix      - logic related to expanding the build matrix, normalizing
#                  configuration for Job::Test instances, evaluating the
#                  final build result etc.
#  * Messages    - helpers for evaluating human readable result messages
#                  (e.g. "Still Failing")
#  * Events      - helpers that are used by notification handlers (and that
#                  TODO probably should be cleaned up and moved to
#                  travis/notification)
class Build < ActiveRecord::Base
  autoload :Compat,      'travis/model/build/compat'
  autoload :Denormalize, 'travis/model/build/denormalize'
  autoload :Matrix,      'travis/model/build/matrix'
  autoload :Messages,    'travis/model/build/messages'
  autoload :Metrics,     'travis/model/build/metrics'
  autoload :States,      'travis/model/build/states'

  include Compat, Matrix, States, Messages
  include Travis::Model::EnvHelpers

  belongs_to :commit
  belongs_to :request
  belongs_to :repository, :autosave => true
  belongs_to :owner, :polymorphic => true
  has_many   :matrix, :as => :source, :order => :id, :class_name => 'Job::Test', :dependent => :destroy
  has_many   :events, :as => :source

  validates :repository_id, :commit_id, :request_id, :presence => true

  serialize :config

  class << self
    def recent(options = {})
      descending.paged(options)
    end

    def was_started
      where(:state => ['started', 'finished'])
    end

    def finished
      where(:state => 'finished')
    end

    def on_branch(branches)
      branches = normalize_to_array(branches)
      pushes.joins(:commit).where(branches.present? ? ["commits.branch IN (?)", branches] : [])
    end

    def by_event_type(event_type)
      event_type == 'pull_request' ?  pull_requests : pushes
    end

    def pushes
      joins(:request).where(:requests => { :event_type => ['push', '', nil] })
    end

    def pull_requests
      joins(:request).where(:requests => { :event_type => 'pull_request' })
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
      scope = recent # TODO in which case we'd call older_than without an argument?
      scope = scope.where('number::integer < ?', (build.is_a?(Build) ? build.number : build).to_i) if build
      scope
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
    self.previous_result ||= last_on_branch.try(:result)
    self.event_type = request.event_type
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

  def config=(config)
    super(config ? normalize_config(config) : {})
  end

  def obfuscated_config
    config.dup.tap do |config|
      next unless config[:env]

      config[:env] = [config[:env]] unless config[:env].is_a?(Array)
      config[:env] = config[:env].map { |env| obfuscate_env(env).join(' ') } if config[:env]
    end
  end

  def pull_request?
    request.pull_request?
  end

  def previous_result
    # TODO remove once previous_result has been populated
    read_attribute(:previous_result) || repository.builds.on_branch(commit.branch).previous(self).try(:result)
  end

  def previous_passed?
    previous_result == 0
  end

  private

    def normalize_env_values(values)
      global = nil

      if values.is_a?(Hash) && (values[:global] || values[:matrix])
        global = values[:global]
        values = values[:matrix]
      end

      if global
        global = [global] unless global.is_a?(Array)
      else
        return values
      end

      values = [values] unless values.is_a?(Array)
      values.map do |line|
        line = [line] unless line.is_a?(Array)
        (line + global).compact
      end
    end


    def normalize_config(config)
      config = config.deep_symbolize_keys
      config[:env] = normalize_env_values(config[:env]) if config[:env]
      config
    end

    def last_on_branch
      repository.builds.on_branch(commit.branch).order(:id).last
    end
end
