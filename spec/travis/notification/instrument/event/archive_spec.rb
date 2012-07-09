require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Archive do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Archive.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.notify
  end

  it 'sends out a received event' do
    event = events[0]
    event.except(:payload).should == {
      :message => "travis.event.handler.archive.notify:received",
      :uuid => Travis.uuid
    }
    payload = event[:payload]
    payload.except(:payload).should == {
      :msg => 'Travis::Event::Handler::Archive#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
    }
    payload[:payload].should_not be_nil
  end

  it 'it sends out a completed event' do
    event = events[1]
    event.except(:payload).should == {
      :message => "travis.event.handler.archive.notify:completed",
      :uuid => Travis.uuid
    }
    payload = event[:payload]
    payload.except(:payload).should == {
      :msg => 'Travis::Event::Handler::Archive#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
    }
    payload[:payload].should_not be_nil
  end
end
