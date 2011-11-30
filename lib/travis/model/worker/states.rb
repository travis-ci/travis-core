require 'active_support/concern'
require 'simple_states'

class Worker
  module States
    extend ActiveSupport::Concern

    included do
      include SimpleStates, Travis::Notifications

      states :created, :starting, :ready, :working, :stopping, :stopped, :errored

      event :start, :to => :started
      event :work,  :to => :working
      event :stop,  :to => :stopped
      event :error, :to => :errored
      event :all, :after => :notify

      after_create do
        notify(:create)
      end
    end
  end
end
