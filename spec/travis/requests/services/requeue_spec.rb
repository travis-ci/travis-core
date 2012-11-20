require 'spec_helper'

describe Travis::Requests::Services::Requeue do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:request) { Factory(:request, :config => {}, :state => :finished) }
  let(:build)   { Factory(:build, :request => request, :state => :finished) }
  let(:service) { described_class.new(user, :build_id => build.id, :token => 'token') }

  before :each do
    service.expects(:service).with(:find_build, :id => build.id).returns(stub(:run => build))
    user.permissions.create!(:repository_id => build.repository_id, :push => true)
  end

  describe 'given the request is authorized' do
    it 'requeues the request' do
      request.expects(:start!)
      service.run
    end
  end
end

describe Travis::Requests::Services::Requeue::Instrument do
  include Support::ActiveRecord

  # let(:payload)   { JSON.parse(GITHUB_PAYLOADS['gem-release']) }
  # let(:service)   { Travis::Services::RequeueRequest.new(nil, build_id: 'push', payload: payload, token: 'token') }
  # let(:publisher) { Travis::Notification::Publisher::Memory.new }
  # let(:event)     { publisher.events.last }

  # before :each do
  #   Travis::Notification.publishers.replace([publisher])
  #   service.run
  # end

  # it 'publishes a event' do
  #   event.should publish_instrumentation_event(
  #     event: 'travis.services.requests.requeue.run:completed',
  #     message: 'Travis::Services::Requests::Requeue#run:completed type="push"',
  #     data: {
  #       type: 'push',
  #       token: 'token',
  #       accept?: true,
  #       payload: payload
  #     }
  #   )
  # end
end
