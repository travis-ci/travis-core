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
      :name => 'ruby-1',
      :host => 'ruby-1.worker.travis-ci.org',
      :repository => 'svenfuchs/minimal',
      :build => { :id => 1 },
      :job => { :id => 1, :number => '2.1' },
      :event => 'worker:ready',
      :queue => 'builds.common'
    }
    event[:payload][:payload].should_not be_nil
  end
end
