require 'active_support/concern'
require 'simple_states'

class Worker
  module States
    extend ActiveSupport::Concern

    included do
      include SimpleStates, Travis::Notifications

      states :created, :starting, :ready, :working, :stopping, :stopped, :errored

      after_create do
        notify(:create, { :name => name, :host => host })
      end
    end

    def ping(report)
      if state != report.state
        update_attributes!(:state => report.state, :last_seen_at => Time.now.utc)
        notify('update', report)
      else
        touch(:last_seen_at)
      end
    end
  end
end
