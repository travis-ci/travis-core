require 'spec_helper'

describe Travis::Addons::Email::Instruments::Task do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Addons::Email::Task }
  let(:payload)   { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:task)      { subject.new(payload, :recipients => %w(svenfuchs@artweb-design.de)) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events[1] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    task.stubs(:process)
    task.run
  end

  it 'publishes a payload' do
    event.except(:payload).should == {
      :message => "travis.addons.email.task.run:completed",
      :uuid => Travis.uuid
    }
    event[:payload].except(:payload).should == {
      :msg => 'Travis::Addons::Email::Task#run for #<Build id=1>',
      :repository => 'svenfuchs/minimal',
      :object_id => 1,
      :object_type => 'Build',
      :email => :finished_email,
      :recipients => %w(svenfuchs@artweb-design.de)
    }
    event[:payload][:payload].should_not be_nil
  end
end

