require 'active_support/concern'
require 'simple_states'

class Request
  module States
    extend ActiveSupport::Concern
    include SimpleStates, Travis::Event

    included do
      states :created, :started, :finished
      event :start,     :to => :started
      event :configure, :to => :configured
      event :finish,    :to => :finished
      event :all, :after => :notify
    end

    # TODO
    # Metriks.meter('github.requests.accepted').mark
    # Metriks.meter('github.requests.rejected').mark
    def start
      configure if accepted?
      finish
    end

    def configure
      self.config = Travis::Github::Config.new(commit.config_url).fetch
    end

    def finish
      build_build if was_configured? && approved?
      self.result = approval.result
      self.message = approval.message
    end

    protected

      delegate :accepted?, :approved?, :to => :approval

      def approval
        @approval ||= Approval.new(self)
      end

      def build_build
        builds.build(:repository => repository, :commit => commit, :config => config, :owner => owner)
      end
  end
end
