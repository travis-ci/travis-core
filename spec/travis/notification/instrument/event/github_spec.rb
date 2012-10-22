require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Github do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Github.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    Broadcast.stubs(:by_repo).returns([broadcast])
    build.stubs(:pull_request?).returns(true)
    handler.stubs(:handle)
    handler.notify
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.event.handler.github.notify:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::Github#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
      :url => 'http://github.com/path/to/comments',
    }
    event[:payload][:payload].should_not be_nil
  end
end
