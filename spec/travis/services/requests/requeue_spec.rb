require 'spec_helper'

describe Travis::Services::Requests::Requeue do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:request) { Factory(:request, :payload => 'the-payload') }
  let(:build)   { Factory(:build, :request => request) }
  let(:service) { Travis::Services::Requests::Requeue.new(user, :build_id => build.id, :token => 'token') }

  before :each do
    service.expects(:service).with(:builds, :one, :id => build.id).returns(stub(:run => build))
  end

  describe 'given the request is authorized' do
    it 'requeues the request' do
      service.expects(:service).with(:requests, :receive, :event_type => 'push', :payload => 'the-payload', :token => 'token').returns(stub(:run => request))
      service.run
    end
  end
end
