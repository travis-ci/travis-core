require 'active_support/concern'
require 'simple_states'
require 'travis/support/amqp'

class Request
  module States
    extend ActiveSupport::Concern
    include Travis::Event

    included do
      include SimpleStates

      states :created, :started, :finished
      event :start,     :to => :started, :after => :configure
      event :configure, :to => :configured, :after => :finish
      event :finish,    :to => :finished
      event :all, :after => :notify
    end

    def configure
      if !accepted?
        Travis.logger.warn("[request:configure] Request not accepted: event_type=#{event_type.inspect} commit=#{commit.try(:commit).inspect} message=#{approval.message.inspect}")
      else
        self.config = fetch_config.merge(config || {})

        if branch_accepted? && config_accepted?
          Travis.logger.info("[request:configure] Request successfully configured commit=#{commit.commit.inspect}")
        else
          self.config = nil
          Travis.logger.warn("[request:configure] Request not accepted: event_type=#{event_type.inspect} commit=#{commit.try(:commit).inspect} message=#{approval.message.inspect}")
        end
      end
      save!
    end

    def finish
      if config.blank?
        Travis.logger.warn("[request:finish] Request not creating a build: config is blank, config=#{config.inspect} commit=#{commit.try(:commit).inspect}")
      elsif !approved?
        Travis.logger.warn("[request:finish] Request not creating a build: not approved commit=#{commit.try(:commit).inspect} message=#{approval.message.inspect}")
      elsif parse_error?
        Travis.logger.info("[request:finish] Request created but Build and Job automatically errored due to a config parsing error. commit=#{commit.try(:commit).inspect}")
        add_parse_error_build
      elsif server_error?
        Travis.logger.info("[request:finish] Request created but Build and Job automatically errored due to a config server error. commit=#{commit.try(:commit).inspect}")
        add_server_error_build
      else
        add_build_and_notify
        Travis.logger.info("[request:finish] Request created a build. commit=#{commit.try(:commit).inspect}")
      end
      self.result = approval.result
      self.message = approval.message
      Travis.logger.info("[request:finish] Request finished. result=#{result.inspect} message=#{message.inspect} commit=#{commit.try(:commit).inspect}")
    end

    def add_build
      builds.create!(:repository => repository, :commit => commit, :config => config, :owner => owner)
    end

    def add_build_and_notify
      add_build.tap do |build|
        # This is a hack that will trigger the creation of a log record via
        # travis-logs.  Should be replaced by a proper API on travis-logs, or more
        # robust lazy creation of missing log records.
        build.matrix.each { |job| store_log(job.id, :empty_part) }
        build.notify(:created) if Travis.config.notify_on_build_created
      end
    end

    protected

      delegate :accepted?, :approved?, :branch_accepted?, :config_accepted?, :to => :approval

      def approval
        @approval ||= Approval.new(self)
      end

      def fetch_config
        Travis.run_service(:github_fetch_config, request: self) # TODO move to a service, have it pass the config to configure
      end

      def parse_error?
        config[".result"] == "parse_error"
      end

      def server_error?
        config[".result"] == "server_error"
      end

      def add_parse_error_build
        Build.transaction do
          build = add_build
          job = build.matrix.first
          store_log(job.id, :parse_error, config[".result_message"])
          job.start!(started_at: Time.now.utc)
          job.finish!(state: "errored",   finished_at: Time.now.utc)
          build.finish!(state: "errored", finished_at: Time.now.utc)
        end
      end

      def add_server_error_build
        Build.transaction do
          build = add_build
          job = build.matrix.first
          store_log(job.id, :server_error)
          job.start!(started_at: Time.now.utc)
          job.finish!(state: "errored",   finished_at: Time.now.utc)
          build.finish!(state: "errored", finished_at: Time.now.utc)
        end
      end

      LOGS = {
        parse_error:  "\033[31;1mERROR\033[0m: An error occured while trying to parse your .travis.yml file.\n\n" +
                      "Please make sure that the file is valid YAML." +
                      "http://lint.travis-ci.org can check your .travis.yml." +
                      "The error was: %s.",
        server_error: "\033[31;1mERROR\033[0m: An error occured while trying to fetch your .travis.yml file.\n\n" +
                      "Is GitHub down? Please contact support@travis-ci.com if this persists.",
        empty_part:   ''
      }

      def store_log(job_id, msg, *args)
        # puts "storing log part #{msg.inspect} on #{job_id}"
        data = { id: job_id, log: LOGS[msg] % args, number: 0, final: true }
        publisher = Travis::Amqp::Publisher.jobs('logs')
        publisher.publish(data, type: 'build:log') # confirm the event name with the Go worker
      end
  end
end
