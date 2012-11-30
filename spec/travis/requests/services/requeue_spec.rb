require 'spec_helper'

describe Travis::Requests::Services::Requeue do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:request) { Factory(:request, config: {}, state: :finished) }
  let(:build)   { Factory(:build, request: request, state: :finished) }
  let(:service) { described_class.new(user, build_id: build.id, token: 'token') }

  before :each do
    Travis.config.roles = {}
    service.stubs(:service).with(:find_build, id: build.id).returns(stub(run: build))
  end

  it 'requeues the request (given no roles configuration and the user has permissions)' do
    user.permissions.create!(repository_id: build.repository_id, pull: true)
    request.expects(:start!)
    service.run
  end

  it 'requeues the request (given roles configuration and the user has permissions)' do
    Travis.config.roles.requeue_request = 'push'
    user.permissions.create!(repository_id: build.repository_id, push: true)
    request.expects(:start!)
    service.run
  end

  it 'does not requeue the request (given no roles configuration and the user does not have permissions)' do
    request.expects(:start!).never
    service.run
  end

  it 'does not requeue the request (given roles configuration and the user does not have permissions)' do
    Travis.config.roles.requeue_request = 'push'
    request.expects(:start!).never
    service.run
  end

  describe 'Instrument' do
    let(:publisher) { Travis::Notification::Publisher::Memory.new }
    let(:event)     { publisher.events.last }

    before :each do
      Travis::Notification.publishers.replace([publisher])
    end

    it 'publishes a event' do
      service.run
      event.should publish_instrumentation_event(
        event: 'travis.requests.services.requeue.run:completed',
        message: "Travis::Requests::Services::Requeue#run:completed build_id=#{build.id} not accepted",
        data: {
          build_id: build.id,
          accept?: false
        }
      )
    end
  end
end
