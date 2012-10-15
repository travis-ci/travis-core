require 'spec_helper'

describe Travis::Services::Requests::Requeue do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:request) { Factory(:request, :config => {}, :state => :finished) }
  let(:build)   { Factory(:build, :request => request, :state => :finished) }
  let(:service) { Travis::Services::Requests::Requeue.new(user, :build_id => build.id, :token => 'token') }

  before :each do
    service.expects(:service).with(:builds, :find_one, :id => build.id).returns(stub(:run => build))
    user.permissions.create!(:repository_id => build.repository_id, :push => true)
  end

  describe 'given the request is authorized' do
    it 'requeues the request' do
      request.expects(:start!)
      service.run
    end
  end
end
