require 'active_record'

class Job < ActiveRecord::Base
  autoload :Configure, 'travis/model/job/configure'
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

  include Cleanup

  has_one    :log, :class_name => "Artifact::Log", :conditions => { :type => "Artifact::Log" }, :dependent => :destroy
  has_many   :artifacts
  belongs_to :repository
  belongs_to :commit
  belongs_to :owner, :polymorphic => true, :autosave => true

  validates :repository_id, :commit_id, :owner_id, :owner_type, :presence => true

  serialize :config

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

  def matrix_config?(config)
    config = config.to_hash.symbolize_keys
    Build.matrix_keys_for(config).map do |key|
      self.config[key.to_sym] == config[key] || commit.branch == config[key]
    end.inject(:&)
  end
end
