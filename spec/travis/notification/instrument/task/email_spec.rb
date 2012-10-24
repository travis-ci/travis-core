require 'spec_helper'

describe Travis::Notification::Instrument::Task::Email do
  include Travis::Testing::Stubs

  let(:payload)   { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:task)      { Travis::Task::Email.new(payload, :recipients => %w(svenfuchs@artweb-design.de)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.task.email.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Task::Email#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :email => :finished_email,
      :recipients => %w(svenfuchs@artweb-design.de)
    }
    event[:payload][:payload].should_not be_nil
  end
end

