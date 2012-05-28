require 'spec_helper'
require 'active_support/core_ext/class'

describe Travis::Notifications::Subscription do
  class Travis::Notifications::Handler::SubscriptionTestHandler
    class_attribute :events
    self.events = []

    EVENTS = /build:finished/

    def initialize(*args)
      self.class.events << args
    end

    def call
    end
  end

  let(:subscription) {Travis::Notifications::Subscription.new(:subscription_test_handler)}

  describe "triggering a notification" do
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
end
