require 'spec_helper'

describe Travis::Addons::Flowdock::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Flowdock::Task }
  let(:payload)   { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:task)      { subject.new(payload, :targets => %w(322fdcced7226b1d66396c68efedb0c1)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.addons.flowdock.task.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::Flowdock::Task#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :targets => %w(322fdcced7226b1d66396c68efedb0c1),
      :message => <<-msg.gsub(/^\s*/, '')
        <ul>
        <li><code><a href="https://github.com/svenfuchs/minimal">svenfuchs/minimal</a></code> build #2 has passed!</li>
        <li>Branch: <code>master</code></li>
        <li>Latest commit: <code><a href="https://github.com/svenfuchs/minimal/commit/62aae5f70ceee39123ef">62aae5f</a></code> by <a href="mailto:svenfuchs@artweb-design.de">Sven Fuchs</a></li>
        <li>Change view: https://github.com/svenfuchs/minimal/compare/master...develop</li>
        <li>Build details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}</li>
        </ul>
      msg
    }
    event[:payload][:payload].should_not be_nil
  end
end

