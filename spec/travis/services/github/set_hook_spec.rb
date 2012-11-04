require 'spec_helper'

describe Travis::Services::Github::SetHook do
  include Travis::Testing::Stubs

  let(:hooks_url)     { 'repos/svenfuchs/minimal/hooks' }
  let(:hook_url)      { 'https://api.github.com/repos/svenfuchs/minimal/hooks/77103' }
  let(:hook_active)   { GH.load GITHUB_PAYLOADS['hook_active'] }
  let(:hook_inactive) { GH.load GITHUB_PAYLOADS['hook_inactive'] }

  def payload(active)
    {
      :name   => 'travis',
      :events => Travis::Services::Github::SetHook::EVENTS,
      :active => active,
      :config => { :user => user.login, :token => user.tokens.first.token, :domain => 'staging.travis-ci.org' }
    }
  end

  def run(active)
    Travis::Services::Github::SetHook.new(user, id: repo.id, active: active).run
  end

  before :each do
    Travis.config.stubs(:service_hook_url).returns('staging.travis-ci.org')
    Repository.stubs(:find).returns(repo)
  end

  describe 'activating' do
    it 'creates a new hook when none exists' do
      GH.expects(:[]).with(hooks_url).returns([])
      GH.expects(:post).with(hooks_url, payload(true)).returns(hook_active)
      GH.expects(:patch).never
      run(true)
    end

    it 'updates and existing hook if it is inactive' do
      GH.expects(:[]).with(hooks_url).returns([hook_inactive])
      GH.expects(:post).never
      GH.expects(:patch).with(hook_url, payload(true))
      run(true)
    end

    it 'does not update and existing hook if it is active' do
      GH.expects(:[]).with(hooks_url).returns([hook_active])
      GH.expects(:post).never
      GH.expects(:patch).never
      run(true)
    end
  end

  describe 'deactivating' do
    it 'creates a new hook when none exists' do
      GH.expects(:[]).with(hooks_url).returns([])
      GH.expects(:post).with(hooks_url, payload(false)).returns(hook_inactive)
      GH.expects(:patch).never
      run(false)
    end

    it 'updates and existing hook if it is active' do
      GH.expects(:[]).with(hooks_url).returns([hook_active])
      GH.expects(:post).never
      GH.expects(:patch).with(hook_url, payload(false))
      run(false)
    end

    it 'creates and updates the hook if github set the active value to true while creating' do
      GH.expects(:[]).with(hooks_url).returns([])
      GH.expects(:post).with(hooks_url, payload(false)).returns(hook_active)
      GH.expects(:patch).with(hook_url, payload(false))
      run(false)
    end

    it 'does not update and existing hook if it is inactive' do
      GH.expects(:[]).with(hooks_url).returns([hook_inactive])
      GH.expects(:post).never
      GH.expects(:patch).never
      run(false)
    end
  end
end

