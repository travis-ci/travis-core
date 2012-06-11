require 'spec_helper'

describe Travis::Notification::Instrument::Task::Campfire do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::Campfire.new(data, :targets => %w(account:token@room)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:data).should == {
      :msg => 'Travis::Task::Campfire#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :targets => %w(account:token@room),
      :message => [
        '[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
        '[travis-ci] Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
        '[travis-ci] Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
      ],
      :result => nil
    }
    event[:data].should_not be_nil
  end
end
