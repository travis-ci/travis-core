require 'spec_helper'

describe Travis::Addons::Webhook::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Webhook::Task }
  let(:payload)   { Travis::Api.data(build, :for => 'webhook', :type => 'build/finished', :version => 'v1') }
  let(:task)      { subject.new(payload, :targets => 'http://example.com') }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.addons.webhook.task.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::Webhook::Task#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :targets => 'http://example.com'
    }
    event[:payload][:payload].should_not be_nil
  end
end

