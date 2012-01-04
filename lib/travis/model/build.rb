require 'active_record'
require 'core_ext/active_record/base'
require 'core_ext/hash/deep_symbolize_keys'

class Build < ActiveRecord::Base
  autoload :Notifications, 'travis/model/build/notifications'
  autoload :Matrix,        'travis/model/build/matrix'
  autoload :Messages,      'travis/model/build/messages'
  autoload :Denormalize,   'travis/model/build/denormalize'
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

    def older_than(build)
      where('number::integer < ?', build.number).order('number DESC').limit(per_page)
    end

    def next_number
      env = defined?(Rails) ? Rails.env : ENV['ENV'] || ENV['RAILS_ENV'] || 'test'
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

  before_create do
    self.number = repository.builds.next_number
    expand_matrix
  end

  def previous_on_branch
    Build.on_branch(commit.branch).previous(self)
  end

  def config=(config)
    super(config.deep_symbolize_keys)
  end
end
