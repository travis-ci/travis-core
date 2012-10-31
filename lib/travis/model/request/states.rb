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
      if accepted? && config.blank?
        self.config = fetch_config
      else
        if not accepted?
          Travis.logger.info("Request #{id} was not accepted: #{approval.message}")
        elsif config.blank?
          Travis.logger.info("Request #{id} had a non-blank config.")
        end
      end
    end

    def finish
      if config.present? && approved?
        add_build
      else
        if not config.present?
          Travis.logger.info("Request #{id} didn't create a build because no config was present.")
        elsif not approved?
          Travis.logger.info("Request #{id} didn't create a build because it wasn't approved: #{approval.message}")
        end
      end
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
        Travis::Services::Github::FetchConfig.new(self).run
      end

      def add_build
        builds.build(:repository => repository, :commit => commit, :config => config, :owner => owner)
      end
  end
end
