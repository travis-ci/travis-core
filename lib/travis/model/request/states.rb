require 'active_support/concern'
require 'simple_states'

class Request

  # A Request goes through the following lifecycle:
  #
  #  * A newly created instance is in the `created` state.
  #  * Its `start` and `configure` events are triggered by the request's
  #    configure job. The `configure` event then triggers the `finish` event
  #    TODO: why is that? why not rename `configure` to `finish`?
  #
  # Once configured a Request will be approved if the given branch is included
  # and not excluded and the repository is not a Rails fork.
  #
  # When the Request is approved then it creates a Build.
  # TODO: why does creating the Build not happen on `finish`?
  module States
    extend ActiveSupport::Concern

    included do
      include SimpleStates, Branches

      states :created, :started, :finished
      event :start,     :to => :started
      event :configure, :to => :configured, :after => :finish
      event :finish,    :to => :finished

      # save the configuration and create a build if approved
      def configure(data)
        update_attributes!(extract_attributes(data))
        create_build! if approved?
      end

      protected

        def approved?
          branch_included?(commit.branch) && !branch_excluded?(commit.branch)
        end

        def extract_attributes(attributes)
          attributes.symbolize_keys.slice(*attribute_names.map(&:to_sym))
        end

        def create_build!
          builds.create!(:repository => repository, :commit => commit, :config => config)
        end
    end
  end
end
