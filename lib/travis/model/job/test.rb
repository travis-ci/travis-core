require 'active_support/core_ext/hash/slice'
require 'simple_states'

class Job

  # Executes a test job (i.e. runs a test suite) remotely and keeps tabs about
  # state changes throughout its lifecycle in the database.
  #
  # Job::Test belongs to a Build as part of the build matrix and will be
  # created with the Build.
  class Test < Job
    include Sponsors, Tagging

    # TODO remove :finished once we've updated the state column
    FINISHED_STATES = [:finished, :passed, :failed, :errored, :canceled]

    include SimpleStates, Travis::Event

    states :created, :queued, :started, :passed, :failed, :errored, :canceled

    event :start,   to: :started
    event :finish,  to: :finished, after: :add_tags
    event :reset,   to: :created, unless: :created?
    event :all, after: [:propagate, :notify]

    def enqueue # TODO rename to queue and make it an event, simple_states should support that now
      update_attributes!(state: :queued, queued_at: Time.now.utc)
      notify(:queue)
    end

    def start(data = {})
      log.update_attributes!(content: '') # TODO this should be in a restart method, right?
      data = data.symbolize_keys.slice(:started_at, :worker)
      data.each { |key, value| send(:"#{key}=", value) }
    end

    def finish(data = {})
      data = data.symbolize_keys.slice(:state, :finished_at, :result)
      data.delete(:state) if data.key?(:result) # TODO legacy payload, remove once workers set :state
      data.each { |key, value| send(:"#{key}=", value) }
    end

    def reset(*)
      self.state = :created
      attrs = %w(started_at queued_at finished_at worker)
      attrs.each { |attr| write_attribute(attr, nil) }
      log.clear!
    end

    def cancelable?
      created?
    end

    def resetable?
      finished?
    end

    def finished?
      FINISHED_STATES.include?(state.to_sym)
    end

    def passed?
      state == :passed || result == 0 # TODO remove as soon we're using state everywhere
    end

    def failed?
      state == :failed || result == 1 # TODO remove as soon we're using state everywhere
    end

    def passed_or_allowed_failure?
      passed? || allow_failure
    end

    def unknown?
      !passed? && !failed? && result == nil
    end

    def notify(event, *args)
      event = :create if event == :reset
      super
    end

    protected

      LEGACY_RESULTS = { 0 => 'passed', 1 => 'failed' }

      def map_legacy_result(result)
        LEGACY_RESULTS[result.to_i] if result.to_s =~ /^[\d]+$/
      end
  end
end
