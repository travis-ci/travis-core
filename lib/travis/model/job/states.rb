require 'active_support/concern'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/except'
require 'core_ext/hash/compact'

class Job

  # Common states logic that is shared by all jobs. Most notable bits:
  #
  #  * Adds an after_commit hook that notifies event handler about the `create`
  #    event once the record has been committed to the db.
  #  * Overwrites update_attributes so that state event related attributes
  #    trigger the respective state event (e.g. updating `started_at` will
  #    instead trigger the `start` event).
  module States
    extend ActiveSupport::Concern

    included do
      after_commit on: :create do
        notify(:create)
      end
    end

    def propagate(*args)
      source.send(*args)
      true
    end

    def update_attributes(attributes)
      if content = attributes.delete(:log)
        log.update_attributes(content: content)
      end
      update_states(attributes.deep_symbolize_keys)
      super
    end

    def passed?
      state == :passed || result == 0 # TODO remove as soon we're using state everywhere
    end

    def passed_or_allowed_failure?
      passed? || allow_failure
    end

    def failed?
      state == :failed || result == 1 # TODO remove as soon we're using state everywhere
    end

    def unknown?
      !passed? && !failed? && result == nil
    end

    protected

      # extracts attributes like :started_at, :finished_at, :config from the given attributes and triggers
      # state changes based on them. See the respective `extract_[state]ing_attributes` methods.
      def update_states(attributes)
        [:start, :finish].each do |state|
          state_attributes = send(:"extract_#{state}ing_attributes", attributes)
          send(:"#{state}!", state_attributes) if state_attributes.present?
        end
      end

      def extract_starting_attributes(attributes)
        extract!(attributes, :started_at)
      end

      def extract!(hash, *keys)
        # arrrgh. is there no ruby or activesupport hash method that does this?
        hash.slice(*keys).compact.tap { |result| hash.except!(*keys) }
      rescue KeyError
        {}
      end
  end
end
