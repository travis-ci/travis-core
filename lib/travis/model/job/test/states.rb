require 'active_support/concern'
require 'simple_states'

class Job
  class Test

    # A Job::Test goes through the following lifecycle:
    #
    #  * A newly created instance is in the `created` state.
    #  * When started it sets attributes from the payload and clears its log
    #    (relevant for re-started jobs).
    #  * When finished it sets attributes from the payload and adds tags.
    #  * On both events it notifies event handlers and then propagates the even
    #    to the build it belongs to.
    #  * It also notifies event handlers of the `log` event whenever something
    #    is appended to the log.
    module States
      extend ActiveSupport::Concern

      # TODO remove status after migrating to result columns
      FINISHING_ATTRIBUTES = [:status, :result, :finished_at]

      included do
        include SimpleStates, Job::States, Travis::Event

        states :created, :queued, :started, :finished # :cloned, :installed, ...

        event :start,   :to => :started
        event :finish,  :to => :finished, :after => :add_tags
        event :all, :after => [:notify, :propagate]
      end

      def enqueue
        update_attributes!(:state => :queued, :queued_at => Time.now.utc)
        notify(:queue)
      end

      def start(data = {})
        log.update_attributes!(:content => '')
        self.started_at = data[:started_at]
        self.worker = data[:worker]
      end

      def finish(data = {})
        FINISHING_ATTRIBUTES.each do |key|
          send(:"#{key}=", data[key]) if data.key?(key)
        end
      end

      def append_log!(chars)
        notify(:log, :_log => chars)
      end

      protected

        def extract_finishing_attributes(attributes)
          extract!(attributes, *FINISHING_ATTRIBUTES)
        end
    end
  end
end
