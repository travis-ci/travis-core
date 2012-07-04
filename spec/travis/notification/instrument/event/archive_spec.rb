require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Archive do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Archive.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.notify
  end

  it 'publishes a payload' do
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
