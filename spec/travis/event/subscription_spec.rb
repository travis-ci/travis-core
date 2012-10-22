require 'spec_helper'
require 'active_support/core_ext/class'

describe Travis::Event::Subscription do
  class Travis::Event::Handler::SubscriptionTestHandler
    class_attribute :events
    self.events = []

    EVENTS = /build:finished/

    def self.notify(*args)
      new(*args).notify
    end

    def initialize(*args)
      self.class.events << args
    end

    def notify
    end
  end

  describe "triggering a notification" do
    let(:subscription) { Travis::Event::Subscription.new(:subscription_test_handler) }

    before do
      subscription.subscriber.events.clear
    end

    it "should notify when the event matches" do
      subscription.notify('build:finished')
      subscription.subscriber.events.should have(1).item
    end

    it "should increment a counter when the event is triggered" do
      expect {
        subscription.notify('build:finished')
      }.to change { Metriks.meter('travis.notifications.subscription_test_handler.build.finished').count }
    end

    it "shouldn't notify when the event doesn't match" do
      subscription.notify('build:started')
      subscription.subscriber.events.should have(0).items
    end
  end

  describe 'a missing event handler' do
    let(:subscription) { Travis::Event::Subscription.new(:missing_handler) }

    it 'lets Travis::Exception handle the NameError' do
      Travis::Exceptions.expects(:handle).with do |exception|
        exception.should be_kind_of(NameError)
      end
      subscription.subscriber
    end

    it 'does not raise the exception' do
     lambda { subscription.subscriber }.should_not raise_error
    end
  end
end
