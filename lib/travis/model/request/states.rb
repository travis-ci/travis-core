require 'active_support/concern'
require 'simple_states'

class Request
  module States
    extend ActiveSupport::Concern
    include SimpleStates, Travis::Event

    included do
      states :created, :started, :finished
      event :start,     :to => :started, :after => :configure
      event :configure, :to => :configured, :after => :finish
      event :finish,    :to => :finished
      event :all, :after => :notify
    end

    def configure
      self.config = fetch_config if accepted? && config.blank?
    end

    def finish
      add_build if config.present? && approved?
      self.result = approval.result
      self.message = approval.message
    end

    def requeueable?
      # finished? && !!builds.all { |build| build.finished? }
      !!builds.all { |build| build.finished? }
    end

    protected

      delegate :accepted?, :approved?, :to => :approval

      def approval
        @approval ||= Approval.new(self)
      end

      def fetch_config
        Travis::Services::Github::FetchConfig.new(commit.config_url).run
      end

      def add_build
        builds.build(:repository => repository, :commit => commit, :config => config, :owner => owner)
      end
  end
end
