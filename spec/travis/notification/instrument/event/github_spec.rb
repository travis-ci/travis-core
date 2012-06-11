require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Github do
  include Travis::Testing::Stubs

  let(:handler)   { Travis::Event::Handler::Github.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    build.stubs(:pull_request?).returns(false)
    handler.stubs(:handle)
    handler.notify
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :msg => 'Travis::Event::Handler::Github#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :result => nil,
      :event => 'build:finished',
      :url => 'http://github.com/path/to/comments'
    }
    event[:payload].should_not be_nil
  end
end
