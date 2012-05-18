require 'spec_helper'
require 'support/active_record'

describe ServiceHook do
  include Support::ActiveRecord

  describe 'set' do
    let(:user)       { stub('user', :login => 'login', :github_oauth_token => 'oauth_token', :tokens => [stub(:token => 'token')]) }
    let(:repository) { Factory(:repository, :owner_name => 'svenfuchs', :name => 'minimal') }

    before :each do
      user.stubs(:authenticated_on_github).yields
    end

    it 'activates a service hook' do
      Travis.config.stubs(:service_hook_url).returns(nil)

      data = { :user => 'login', :token => 'token', :domain => '', :active => true }
      GH.expects(:post).with('repos/svenfuchs/minimal/hooks', data)

      repository.service_hook.set(true, user)
      repository.should be_persisted
      repository.should be_active
    end

    it 'activates a service hook with a custom service hook url' do
      Travis.config.stubs(:service_hook_url).returns('staging.travis-ci.org')

      data = { :user => 'login', :token => 'token', :domain => 'staging.travis-ci.org', :active => true }
      GH.expects(:post).with('repos/svenfuchs/minimal/hooks', data)

      repository.service_hook.set(true, user)
      repository.should be_persisted
      repository.should be_active
    end

    it 'removes a service hook' do
      data = { :user => '', :token => '', :domain => '', :active => false }
      GH.expects(:post).with('repos/svenfuchs/minimal/hooks', data)

      repository.service_hook.set(false, user)
      repository.should be_persisted
      repository.should_not be_active
    end
  end
end

