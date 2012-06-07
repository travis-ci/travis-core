require 'spec_helper'
require 'core_ext/module/include'

describe Travis::Exceptions::Handling do
  let(:klass) do
    Class.new do
      extend Travis::Exceptions::Handling

      attr_reader :called

      def outer
        inner
      end

      def inner # so there's something we can stub for raising
        @called = true
      end
    end
  end

  let(:object) { klass.new }

  before :each do
    klass.rescues :outer
  end

  it 'calls the original implementation' do
    object.outer
    object.called.should be_true
  end

  it 'rescues exceptions' do
    object.stubs(:inner).raises(Exception)
    lambda { object.outer }.should_not raise_error
  end

  it 'sends exceptions to the exception handler' do
    exception = Exception.new
    object.stubs(:inner).raises(exception)
    Travis::Exceptions.expects(:handle).with(exception)
    object.outer
  end
end
