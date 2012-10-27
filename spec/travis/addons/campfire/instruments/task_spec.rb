require 'spec_helper'

describe Travis::Addons::Campfire::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Campfire::Task }
  let(:payload)   { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:task)      { subject.new(payload, :targets => %w(account:token@room)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.addons.campfire.task.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::Campfire::Task#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :targets => %w(account:token@room),
      :message => [
        '[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
        '[travis-ci] Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
        "[travis-ci] Build details: http://travis-ci.org/svenfuchs/minimal/builds/1"
      ]
    }
    event[:payload][:payload].should_not be_nil
  end
end

