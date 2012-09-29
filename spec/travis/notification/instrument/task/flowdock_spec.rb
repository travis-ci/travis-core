require 'spec_helper'

describe Travis::Notification::Instrument::Task::Flowdock do
  include Travis::Testing::Stubs

  let(:data)      { Travis::Api.data(build, :for => 'event', :version => 'v2') }
  let(:task)      { Travis::Task::Flowdock.new(data, :targets => %w(322fdcced7226b1d66396c68efedb0c1)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.flowdock.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:data).should == {
      :msg => 'Travis::Task::Flowdock#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :targets => %w(322fdcced7226b1d66396c68efedb0c1),
      :message => <<-EOM
<ul>
<li>svenfuchs/minimal build #2 has passed</li>
<li>Branch: <code>master</code></li>
<li>Latest commit: <code>62aae5f</code> by Sven Fuchs</li>
<li>Change view: https://github.com/svenfuchs/minimal/compare/master...develop</li>
<li>Build details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}</li>
</ul>
      EOM
    }
    event[:payload][:data].should_not be_nil
  end
end
