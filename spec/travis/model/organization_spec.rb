require 'spec_helper'
require 'support/active_record'
require 'support/webmock'

describe Organization do
  include Support::ActiveRecord

  before :each do
    body = '[ { "login": "travis-pro", "id": 1 } ]'
    stub_request(:get, "https://api.github.com/user/orgs").to_return(:body => body)
  end

  describe 'sync_for' do
    let(:user)   { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
    let(:action) { lambda { Organization.sync_for(user) } }

    it 'finds existing organizations' do
      Organization.create!(:github_id => 1)
      action.should_not change(Organization, :count)
    end

    it 'finds existing organizations' do
      org = Organization.create!(:github_id => 1)
      action.call
      org.reload.login.should == 'travis-pro'
    end

    it 'creates missing organizations' do
      action.should change(Organization, :count).by(1)
    end
  end
end
