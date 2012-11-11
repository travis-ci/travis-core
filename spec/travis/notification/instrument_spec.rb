require 'spec_helper'

describe Travis::Notification::Instrument do
  let(:klass) do
    Class.new(Travis::Notification::Instrument) do
      def foo_completed
        42
      end
    end
  end

  it 'automatically generates a received event' do
    klass.should be_method_defined(:foo_received)
    klass.new('', :foo, :received, {}).foo_received.should == 42
  end

  it 'automatically generates a failed event' do
    klass.should be_method_defined(:foo_failed)
    klass.new('', :foo, :failed, {}).foo_failed.should == 42
  end
end
