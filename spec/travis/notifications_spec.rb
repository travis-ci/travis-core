require 'spec_helper'
require 'support/active_record'

# A more high-level test for notifications as a whole
describe Travis::Notifications do
  include Travis::Notifications
  include Support::ActiveRecord

  let(:build)    { Factory(:build, :config => { 'notifications' => { 'campfire' => 'evome:apitoken@42' } }) }
  describe "notifying of an event" do
    describe "campfire" do
      before do
        Travis.config.notifications.handlers = [:campfire]
      end

      it "should not publish start events to campfire" do
        Travis::Notifications::Handler::Campfire.any_instance.expects(:notify).never
        notify("build:started", build)
      end

      it "should publish finish events to campfire" do
        Travis::Notifications::Handler::Campfire.any_instance.expects(:notify)
        notify("build:finished", build)
      end
    end

    describe "webhooks" do
      before do
        Travis.config.notifications.handlers = [:webhook]
      end

      it "should publish start events to webhooks" do
        targets = ['http://evome.fr/notifications', 'http://example.com/']
        build.config[:notifications][:webhooks] = {:urls => targets}
        Travis::Notifications::Handler::Webhook.any_instance.expects(:notify)
        notify("build:started")
      end

      it "should publish finish events to webhooks" do
        targets = ['http://evome.fr/notifications', 'http://example.com/']
        build.config[:notifications][:webhooks] = {:urls => targets}
        Travis::Notifications::Handler::Webhook.any_instance.expects(:notify)
        notify("build:finish")
      end
    end
  end
end
