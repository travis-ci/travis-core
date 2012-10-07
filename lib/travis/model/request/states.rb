require 'active_support/concern'
require 'simple_states'

class Request
  module States
    extend ActiveSupport::Concern
    include SimpleStates

    included do
      states :created, :started, :finished
      event :start,     :to => :started, :after => :configure
      event :configure, :to => :configured, :after => :finish
      event :finish,    :to => :finished
    end

    def configure
      self.config = fetch_config if accepted? && config.blank?
    end

    def finish
      add_build if config.present? && approved?
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
        Travis::Github::Config.new(commit.config_url).fetch
      end

      def add_build
        builds.build(:repository => repository, :commit => commit, :config => config, :owner => owner)
      end
  end
end
