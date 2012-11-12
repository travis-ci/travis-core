require 'spec_helper'

describe Travis::Addons::Irc::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Irc::Task }
  let(:payload)   { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:task)      { subject.new(payload, channels: ['irc.freenode.net:1234#travis']) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a event' do
    event.should publish_instrumentation_event(
      event: 'travis.addons.irc.task.run:completed',
      message: 'Travis::Addons::Irc::Task#run for #<Build id=1>',
    )
    event[:data].except(:payload).should == {
      repository: 'svenfuchs/minimal',
      object_id: 1,
      object_type: 'Build',
      channels: ['irc.freenode.net:1234#travis'],
      messages: [
        'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
        'Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
        'Build details : http://travis-ci.org/svenfuchs/minimal/builds/1'
      ]
    }
    event[:data][:payload].should_not be_nil
  end
end

