require 'spec_helper'
require 'support/active_record'

describe ServiceHook do
  include Support::ActiveRecord

  describe 'set' do
    let(:user)       { stub('user', :login => 'login', :github_oauth_token => 'oauth_token', :tokens => [stub(:token => 'user_token')]) }
    let(:repository) { Factory(:repository, :owner_name => 'svenfuchs', :name => 'minimal') }

    it 'activates a service hook' do
      Travis::GithubApi.expects(:add_service_hook).with('svenfuchs', 'minimal', 'oauth_token',
        :user   => 'login',
        :token  => 'user_token'
      )

      repository.service_hook.set(true, user)
      repository.should be_persisted
      repository.should be_active
    end

    it 'activates a service hook with a custom service hook url' do
      Travis.config.stubs(:service_hook_url).returns('staging.travis-ci.org')

      Travis::GithubApi.expects(:add_service_hook).with('svenfuchs', 'minimal', 'oauth_token',
        :user   => 'login',
        :token  => 'user_token',
        :domain => 'staging.travis-ci.org'
      )

      repository.service_hook.set(true, user)
      repository.should be_persisted
      repository.should be_active
    end

    it 'removes a service hook' do
      Travis::GithubApi.expects(:remove_service_hook).with('svenfuchs', 'minimal', 'oauth_token')

      repository.service_hook.set(false, user)
      repository.should be_persisted
      repository.should_not be_active
    end
  end
end

