require 'active_support/concern'
require 'simple_states'

class Worker
  module States
    extend ActiveSupport::Concern

    included do
      include SimpleStates, Travis::Notifications

      states :created, :starting, :ready, :working, :stopping, :stopped, :errored
    end

    def ping(report)
      update_attributes!(:state => report.state, :last_seen_at => Time.now.utc)
      notify('update', report)
    end
  end
end
