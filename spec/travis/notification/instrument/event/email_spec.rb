require 'spec_helper'

describe Travis::Notification::Instrument::Event::Handler::Email do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Event::Handler::Email }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    subject.any_instance.stubs(:handle)
    subject.notify('build:finished', build)
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.event.handler.email.notify:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Event::Handler::Email#notify(build:finished) for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :request_id => 1,
      :object_id => 1,
      :object_type => 'Build',
      :event => 'build:finished',
      :recipients => ['svenfuchs@artweb-design.de'],
    }
    event[:payload][:payload].should_not be_nil
  end
end
