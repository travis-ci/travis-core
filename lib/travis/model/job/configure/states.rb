require 'active_support/concern'
require 'simple_states'

class Job
  class Configure

    # A Job::Configure goes through the following lifecycle:
    #
    #  * A newly created instance is in the `created` state.
    #  * When started it propagates the event to the Request it belongs to.
    #  * When finished it sets the configuration to the Request.
    #  * After both `start` and `finish` events listeners will be notified.
    module States
      extend ActiveSupport::Concern

      included do
        include SimpleStates, Job::States, Travis::Notifications

        states :created, :started, :finished

        event :start,  :to => :started,  :after => :propagate
        event :finish, :to => :finished, :after => :configure_source # TODO why not just propagate here?
        event :all, :after => :notify

        def finish(data)
          [:config, :finished_at].each do |key|
            send(:"#{key}=", data[key]) if data.key?(key)
          end
        end

        def configure_source(event, data)
          source.configure!(data)
        end

        protected

          def extract_finishing_attributes(attributes)
            extract!(attributes, :config)
          end
      end
    end
  end
end
