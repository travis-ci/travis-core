require 'spec_helper'

describe Travis::Notification::Instrument::Services::Hooks::Update do
  include Travis::Testing::Stubs

  let(:service) { Travis::Services::Hooks::Update.new(user, params) }
  let(:params)  { { :id => repository.id, :active => 'true' } }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.last }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    Travis::Services::Hooks::FindOne.any_instance.stubs(:run).returns(hook)
    hook.stubs(:set)
  end

  it 'publishes a payload' do
    service.run
    event.should == {
      :message => "travis.services.hooks.update.run:completed",
      :uuid => Travis.uuid,
      :payload => {
        :msg => 'Travis::Services::Hooks::Update#run for svenfuchs/minimal active=true (svenfuchs)',
        :result => true
      }
    }
  end
end

