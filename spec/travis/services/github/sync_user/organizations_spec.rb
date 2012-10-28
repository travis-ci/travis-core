require 'spec_helper'

describe Travis::Services::Github::SyncUser::Organizations do
  include Support::ActiveRecord

  describe 'run' do
    let(:subject) { Travis::Services::Github::SyncUser::Organizations }
    let(:user)    { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
    let(:action)  { lambda { subject.new(user).run } }
    let(:data)    { [{ 'id' => 1, 'login' => 'login' }] }

    before :each do
      GH.stubs(:[]).with('user/orgs').returns(data)
    end

    describe 'creates missing organizations' do
      it 'creates missing organizations' do
        action.should change(Organization, :count).by(1)
      end

      it 'makes the user a member of the organization' do
        action.call
        user.reload.organizations.should include(Organization.first)
      end
    end

    describe 'updates existing organizations' do
      it 'does not create a new organization' do
        Organization.create!(:github_id => 1)
        action.should_not change(Organization, :count)
      end

      it 'updates the organization attributes' do
        org = Organization.create!(:github_id => 1, :login => 'old-login')
        action.call
        org.reload.login.should == 'login'
      end

      it 'makes the user a member of the organization' do
        action.call
        user.organizations.should include(Organization.first)
      end
    end

    it 'removes stale organization memberships' do
      user.organizations << Organization.create!(:github_id => 1)
      action.call
      user.organizations.should include(Organization.first)
    end
  end
end
