require 'spec_helper'

describe Travis::Addons::Campfire::Instruments::EventHandler do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Campfire::EventHandler }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:build)     { stub_build(:config => { :notifications => { :campfire => 'campfire_room' } }) }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    subject.any_instance.stubs(:handle)
    subject.notify('build:finished', build)
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.addons.campfire.event_handler.notify:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :event => 'build:finished',
      :targets => ['campfire_room'],
      :msg => 'Travis::Addons::Campfire::EventHandler#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build'
    }
    event[:payload][:payload].should_not be_nil
  end
end
