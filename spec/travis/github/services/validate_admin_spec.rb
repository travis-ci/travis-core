require 'spec_helper'

describe Travis::GitHub::Services::ValidateAdmin do
  include Travis::Testing::Stubs
  include Support::Log

  let(:permissions) { {} }
  let(:repo)        { stub_repo(slug: 'travis-ci/travis-core') }
  let(:error)       { GH::Error.new.tap { |e| e.stubs(info: { response_status: status }) } }
  let(:result)      { described_class.new(nil, repo: repo, user: user).run }

  before :each do
    user.stubs(:update_attributes!)
    GH.stubs(:[]).with("repos/#{repo.slug}").returns('permissions' => permissions)
  end

  it 'requests repo data from GitHub' do
    GH.expects(:[]).with("repos/#{repo.slug}")
    result
  end

  describe 'if the user has admin permissions' do
    let(:permissions) { { 'admin' => true } } # TODO what does GitHub actually return?

    it 'returns true ' do
      result.should be_true
    end
  end

  describe 'if the user does not have admin permissions any more' do
    let(:permissions) { { foo: :bar } }

    it 'updates the user permissions' do
      user.expects(:update_attributes!).with(permissions: { foo: :bar })
      result
    end

    it 'logs a notice' do
      capture_log { result }.should include('svenfuchs no longer has admin access to travis-ci/travis-core')
    end
  end

  describe 'if the request times out' do
    before :each do
      GH.stubs(:[]).with("repos/#{repo.slug}").raises(Timeout::Error.new)
    end

    it 'logs a notice' do
      capture_log { result }.should include('timed out after 2s retrieving repository info for travis-ci/travis-core for svenfuchs')
    end

    it 'does not update user permissions' do
      user.expects(:update_attributes!).never
      result
    end
  end

  describe 'GH errors' do
    before :each do
      GH.stubs(:[]).with("repos/#{repo.slug}").raises(error)
    end

    describe 'if GitHub returns 401 (the token is invalid)' do
      let(:status) { 401 }

      it 'removes the github_oauth_token from the user' do
        user.expects(:update_attributes!).with(github_oauth_token: '')
        result
      end

      it 'logs a notice' do
        capture_log { result }.should include('token for svenfuchs no longer valid')
      end
    end

    describe 'if GitHub returns 404 (the user does not have access any more)' do
      let(:status) { 404 }

      it 'removes permissions for this repo from the user' do
        user.expects(:update_attributes!).with(permissions: {})
        result
      end

      it 'logs a notice' do
        capture_log { result }.should include('svenfuchs no longer has any access to travis-ci/travis-core')
      end
    end

    describe 'if GitHub any other error' do
      let(:status) { 500 }

      it 'logs a notice' do
        capture_log { result }.should include('error retrieving repository info for travis-ci/travis-core for svenfuchs')
      end
    end
  end
end
