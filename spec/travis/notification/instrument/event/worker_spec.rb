require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Worker do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Worker.new('job:test:created', test) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.notify
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.event.handler.worker.notify:call",
      :result => nil,
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::Worker#notify(job:test:created) for #<Job::Test id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Job::Test',
      :event => 'job:test:created',
      :queue => 'builds.common'
    }
    event[:payload][:payload].should_not be_nil
  end
end
