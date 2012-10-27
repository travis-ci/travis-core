require 'spec_helper'
describe Travis::Addons::GithubStatus::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::GithubStatus::Task }
  let(:payload)   { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:task)      { subject.new(payload, :token => '12345') }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.addons.github_status.task.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::GithubStatus::Task#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :url => '/repos/svenfuchs/minimal/statuses/62aae5f70ceee39123ef'
    }
    event[:payload][:payload].should_not be_nil
  end
end

