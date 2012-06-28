require 'spec_helper'

describe Travis::Notification::Instrument::Task::Github do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::Github.new(data, :url => 'https://api.github.com/repos/svenfuchs/minimal/issues/1/comments') }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.first }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.github.run:call",
      :result => nil,
      :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::Github#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :message => 'This pull request [passes](http://travis-ci.org/svenfuchs/minimal/builds/1) (merged head-com into base-com).',
      :url => 'https://api.github.com/repos/svenfuchs/minimal/issues/1/comments'
    }
    event[:payload][:data].should_not be_nil
  end
end

