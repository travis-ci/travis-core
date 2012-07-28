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
  end
end
