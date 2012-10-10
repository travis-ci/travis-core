require 'spec_helper'

describe Travis::Notification::Instrument::Task::Campfire do
  include Support::ActiveRecord
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::Campfire.new(data, :targets => %w(account:token@room)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    Travis::Features.stubs(:active?).returns(true)
    Repository.stubs(:find).returns(stub('repo'))
    Url.stubs(:shorten).returns(url)
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.campfire.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::Campfire#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :targets => %w(account:token@room),
      :message => [
        '[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
        '[travis-ci] Change view: http://trvs.io/short',
        "[travis-ci] Build details: http://trvs.io/short"
      ]
    }
    event[:payload][:data].should_not be_nil
  end
end
