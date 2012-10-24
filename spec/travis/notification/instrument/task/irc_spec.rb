require 'spec_helper'

describe Travis::Notification::Instrument::Task::Irc do
  include Travis::Testing::Stubs

  let(:payload)   { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:task)      { Travis::Task::Irc.new(payload, :channels => ['irc.freenode.net:1234#travis']) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    # TODO ...
    Travis::Features.stubs(:active?).returns(false)
    Repository.stubs(:find).returns(repository)
    Url.stubs(:shorten).returns(url)

    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.irc.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Task::Irc#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :channels => ['irc.freenode.net:1234#travis'],
      :messages => [
        'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): The build passed.',
        'Change view : https://github.com/svenfuchs/minimal/compare/master...develop',
        'Build details : http://travis-ci.org/svenfuchs/minimal/builds/1'
      ]
    }
    event[:payload][:payload].should_not be_nil
  end
end

