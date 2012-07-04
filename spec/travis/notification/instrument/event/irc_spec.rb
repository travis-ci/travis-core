require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Irc do
  include Travis::Testing::Stubs

  let(:build)     { stub_build(:config => { :notifications => { :irc => 'irc.freenode.net:1234#travis' } }) }
  let(:handler)   { Travis::Event::Handler::Irc.new('build:finished', build) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    handler.stubs(:handle)
    handler.notify
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.event.handler.irc.notify:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::Irc#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
      :channels => { ['irc.freenode.net', '1234'] => ['travis'] },
    }
    event[:payload][:payload].should_not be_nil
  end
end
