require 'spec_helper'

describe Travis::Services::Hooks do
  include Support::ActiveRecord

  let(:user)    { User.first || Factory(:user) }
  let(:repo)    { Factory(:repository) }
  let(:service) { Travis::Services::Hooks::Update.new(user, params) }

  before :each do
    user.permissions.create!(:repository => repo, :admin => true)
  end

  describe 'run' do
    let(:params) { { :id => repo.id, :active => 'true' } }

    before :each do
      ServiceHook.any_instance.stubs(:set)
    end

    it 'sets the given :active param to the hook' do
      ServiceHook.any_instance.expects(:set).with(true, user)
      service.run
    end

    it 'returns the repository' do
      service.run.should == repo
    end
  end
end
