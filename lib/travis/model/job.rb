require 'active_record'

# Job models a unit of work that is run on a remote worker.
#
# There currently only one job type:
#
#  * Job::Test belongs to a Build (one or many Job::Test instances make up a
#    build matrix) and executes a test suite with parameters defined in the
#    configuration.
class Job < ActiveRecord::Base
  autoload :Compat,    'travis/model/job/compat'
  autoload :Cleanup,   'travis/model/job/cleanup'
  autoload :Queue,     'travis/model/job/queue'
  autoload :States,    'travis/model/job/states'
  autoload :Sponsors,  'travis/model/job/sponsors'
  autoload :Tagging,   'travis/model/job/tagging'
  autoload :Test,      'travis/model/job/test'

  class << self
    def queued
      where(:state => :created)
    end
  end

  include Cleanup, Compat

  has_one    :log, :class_name => 'Artifact::Log', :conditions => { :type => 'Artifact::Log' }, :dependent => :destroy
  has_many   :artifacts
  belongs_to :repository
  belongs_to :commit
  belongs_to :source, :polymorphic => true, :autosave => true
  belongs_to :owner, :polymorphic => true

  validates :repository_id, :commit_id, :source_id, :source_type, :presence => true

  serialize :config

  delegate :request_id, :to => :source # TODO denormalize

  after_initialize do
    self.config = {} if config.nil?
  end

  before_create do
    build_log
    self.state = :created if self.state.nil?
    self.queue = Queue.for(self).name
  end

  def duration
    started_at && finished_at ? finished_at - started_at : nil
  end

  def config=(config)
    super(config ? config.deep_symbolize_keys : {})
  end

  def obfuscated_config
    self.config.dup.tap do |config|
      if config[:env]
        config[:env] = obfuscate_env_vars(config[:env])
      end
    end
  end

  def matrix_config?(config)
    config = config.to_hash.symbolize_keys
    Build.matrix_keys_for(config).map do |key|
      self.config[key.to_sym] == config[key] || commit.branch == config[key]
    end.inject(:&)
  end
end
