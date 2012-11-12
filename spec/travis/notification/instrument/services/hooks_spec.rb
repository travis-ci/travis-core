require 'spec_helper'

describe Travis::Notification::Instrument::Services::Hooks::Update do
  include Travis::Testing::Stubs

  let(:service)   { Travis::Services::Hooks::Update.new(user, params) }
  let(:params)    { { id: repository.id, active: 'true' } }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:event)     { publisher.events.last }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    Travis::Services::Github::SetHook.any_instance.stubs(:run)
    user.stubs(:service_hook).returns(repo)
    repo.stubs(:update_column).returns(true)
  end

  it 'publishes a event' do
    service.run
    event.should publish_instrumentation_event(
      event: 'travis.services.hooks.update.run:completed',
      message: 'Travis::Services::Hooks::Update#run:completed for svenfuchs/minimal active=true (svenfuchs)',
      result: true
    )
  end
end

