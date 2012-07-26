require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Worker do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Worker.new('worker:ready', worker) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.stubs(:job).returns(test)
    test.stubs(:enqueue)
    handler.notify
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.event.handler.worker.notify:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::Worker#notify(worker:ready) for #<Worker id=1>',
      :object_id => 1,
      :object_type => 'Worker',
      :event => 'worker:ready',
      :queue => 'builds.common'
    }
    event[:payload][:payload].should_not be_nil
  end
end
