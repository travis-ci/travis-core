require 'spec_helper'

describe ServiceHook do
  include Support::ActiveRecord

  describe 'set' do
    let(:user)       { stub('user', :login => 'svenfuchs', :github_oauth_token => 'oauth_token', :tokens => [stub(:token => 'token')]) }
    let(:repository) { Factory(:repository, :owner_name => 'svenfuchs', :name => 'minimal') }
    let(:hooks_url)  { 'repos/svenfuchs/minimal/hooks' }
    let(:hook_url)   { "https://api.github.com/repos/svenfuchs/minimal/hooks/77103" }
    let(:active)     { GH.load GITHUB_PAYLOADS['hook_active'] }
    let(:inactive)   { GH.load GITHUB_PAYLOADS['hook_inactive'] }

    def update_payload(active)
      {
        :name   => 'travis',
        :events => ServiceHook::EVENTS,
        :active => active,
        :config => { :user => user.login, :token => user.tokens.first.token, :domain => 'staging.travis-ci.org' }
      }
    end

    before :each do
      Travis.config.stubs(:service_hook_url).returns('staging.travis-ci.org')
    end

    describe 'activating' do
      it 'creates a new hook when none exists' do
        GH.expects(:[]).with(hooks_url).returns([])
        GH.expects(:post).with(hooks_url, update_payload(true)).returns(active)
        GH.expects(:patch).never

        repository.service_hook.set(true, user)
        repository.should be_persisted
        repository.should be_active
      end

      it 'updates and existing hook if it is inactive' do
        GH.expects(:[]).with(hooks_url).returns([inactive])
        GH.expects(:post).never
        GH.expects(:patch).with(hook_url, update_payload(true))

        repository.service_hook.set(true, user)
        repository.should be_persisted
        repository.should be_active
      end

      it 'does not update and existing hook if it is active' do
        GH.expects(:[]).with(hooks_url).returns([active])
        GH.expects(:post).never
        GH.expects(:patch).never

        repository.service_hook.set(true, user)
        repository.should be_persisted
        repository.should be_active
      end
    end

    describe 'deactivating' do
      it 'creates a new hook when none exists' do
        GH.expects(:[]).with(hooks_url).returns([])
        GH.expects(:post).with(hooks_url, update_payload(false)).returns(inactive)
        GH.expects(:patch).never

        repository.service_hook.set(false, user)
        repository.should be_persisted
        repository.should_not be_active
      end

      it 'updates and existing hook if it is active' do
        GH.expects(:[]).with(hooks_url).returns([active])
        GH.expects(:post).never
        GH.expects(:patch).with(hook_url, update_payload(false))

        repository.service_hook.set(false, user)
        repository.should be_persisted
        repository.should_not be_active
      end

      it 'creates and updates the hook if github set the active value to true while creating' do
        GH.expects(:[]).with(hooks_url).returns([])
        GH.expects(:post).with(hooks_url, update_payload(false)).returns(active)
        GH.expects(:patch).with(hook_url, update_payload(false))

        repository.service_hook.set(false, user)
        repository.should be_persisted
        repository.should_not be_active
      end

      it 'does not update and existing hook if it is inactive' do
        GH.expects(:[]).with(hooks_url).returns([inactive])
        GH.expects(:post).never
        GH.expects(:patch).never

        repository.service_hook.set(false, user)
        repository.should be_persisted
        repository.should_not be_active
      end
    end
  end
end

