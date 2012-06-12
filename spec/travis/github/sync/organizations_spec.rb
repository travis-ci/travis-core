require 'spec_helper'

describe Travis::Github::Sync::Organizations do
  include Support::ActiveRecord

  before :each do
    GH.stubs(:[]).with('user/orgs').returns [
      { 'id' => 1, 'name' => 'The Org', 'login' => 'the-org'  }
    ]
  end

  describe 'sync_for' do
    let(:user)   { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
    let(:action) { lambda { Travis::Github::Sync::Organizations.new(user).run } }

    it 'finds existing organizations' do
      Organization.create!(:github_id => 1)
      action.should_not change(Organization, :count)
    end

    it 'finds existing organizations' do
      org = Organization.create!(:github_id => 1)
      action.call
      org.reload.login.should == 'the-org'
    end

    it 'creates missing organizations' do
      action.should change(Organization, :count).by(1)
    end
  end
end
