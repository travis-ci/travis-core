require 'spec_helper'

describe Travis::Notification::Instrument do
  let(:klass) do
    Class.new do
      extend Travis::Instrumentation
      def self.name; 'Travis::Foo::Bar'; end
      def run; end
      instrument :run
    end
  end

  let(:instrument) do
    Class.new(Travis::Notification::Instrument) do
      def self.name; 'Travis::Foo::Bar::Instrument'; end
      def run_completed; end
    end
  end

  describe 'attach_to' do
    it 'subscribes to ActiveSupport::Notifications using the class name as a namespace' do
      ActiveSupport::Notifications.expects(:subscribe).times(3).with do |subscription|
        subscription.inspect.should =~ /travis\.foo\.bar.*run:(received|completed|failed)/
      end
      instrument.attach_to(klass)
    end

    it 'subscribes to ActiveSupport::Notifications using an instrumentation key if defined' do
      klass.instrumentation_key = 'travis.bar'
      ActiveSupport::Notifications.expects(:subscribe).times(3).with do |subscription|
        subscription.inspect.should =~ /travis\.bar.*run:(received|completed|failed|)/
      end
      instrument.attach_to(klass)
    end
  end

  # it 'calls a run_received method if defined'
  # it 'calls publish if run_received is not defined'
  # it 'calls a run_completed method if defined'
  # it 'calls publish if run_completed is not defined'
  # it 'calls a run_failed method if defined'
  # it 'calls publish if run_failed is not defined'
end
