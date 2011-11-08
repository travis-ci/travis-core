require 'active_support/concern'
require 'simple_states'

class Request
  module States
    extend ActiveSupport::Concern

    included do
      include SimpleStates, Branches

      states :created, :started, :finished
      event :start,     :to => :started
      event :configure, :to => :configured, :after => :finish
      event :finish,    :to => :finished

      def approved?
        branch_included?(commit.branch) && !branch_excluded?(commit.branch) && !rails_fork?
      end

      def configure(data)
        update_attributes!(extract_attributes(data))
        create_build! if approved?
      end

      protected

        def extract_attributes(attributes)
          attributes.symbolize_keys.slice(*attribute_names.map(&:to_sym))
        end

        def rails_fork?
          repository.slug != 'rails/rails' && repository.slug =~ %r(/rails$)
        end
    end
  end
end
