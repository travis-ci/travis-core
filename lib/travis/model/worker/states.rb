require 'active_support/concern'
require 'simple_states'

class Worker
  module States
    extend ActiveSupport::Concern

    included do
      include SimpleStates, Travis::Event

      states :created, :starting, :ready, :working, :stopping, :stopped, :errored

      after_create do
        notify(:add)
      end
    end

    def ping(report)
      if state != report.state
        update_attributes!(report.merge(:last_seen_at => Time.now.utc).to_hash)
        notify('update')
      else
        touch(:last_seen_at)
      end
    end
  end
end
