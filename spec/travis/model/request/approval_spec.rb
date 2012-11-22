require 'spec_helper'

describe Request::Approval do
  include Travis::Testing::Stubs

  let(:approval) { Request::Approval.new(request) }

  describe 'accepted?' do
    it 'accepts a request that has a commit, belongs to a public repository, is not skipped and does not belong to the github_pages branch and it is not a rails fork' do
      approval.should be_accepted
    end

    it 'does not accept a request that does not have a commit' do
      request.stubs(:commit).returns(nil)
      approval.should_not be_accepted
    end

    it 'does not accept a request that belongs to a private repository' do
      request.repository.stubs(:private?).returns(true)
      approval.should_not be_accepted
    end

    it 'does not accept a request that belongs to a blacklisted repository' do
      request.repository.stubs(:slug).returns('svenfuchs/rails')
      approval.should_not be_accepted
    end

    it 'does not accept a request that is skipped (using the commit message)' do
      request.commit.stubs(:message).returns('update README [ci:skip]')
      approval.should_not be_accepted
    end

    it 'does not accept a request that belongs to the github_pages branch' do
      request.commit.stubs(:ref).returns('gh_pages')
      approval.should_not be_accepted
    end
  end

  describe 'approved?' do
    xit 'should be specified'
  end

  describe 'message' do
    it 'returns "missing commit" if the commit is missing' do
      request.stubs(:commit).returns(nil)
      approval.message.should == 'missing commit'
    end

    it 'returns "private repository" if the repository is private' do
      request.repository.stubs(:private?).returns(true)
      request.stubs(:config).returns({key: 'value'})
      approval.message.should == 'private repository'
    end

    it 'returns "blacklisted repository" if the repository is a blacklisted repository' do
      request.repository.stubs(:slug).returns('svenfuchs/rails')
      approval.message.should == 'blacklisted repository'
    end

    it 'returns "github pages branch" if the branch is a github pages branch' do
      request.commit.stubs(:ref).returns('gh-pages')
      approval.message.should == 'github pages branch'
    end

    it 'returns "missing config" if the config is not present' do
      request.stubs(:config).returns(nil)
      approval.message.should == 'missing config'
    end

    it 'returns "branch not included or excluded" if the branch was not approved' do
      request.commit.stubs(:branch).returns('feature')
      request.stubs(:config).returns('branches' => { 'only' => 'master' })
      approval.message.should == 'branch not included or excluded'
    end
  end

  describe 'skipped?' do
    it 'returns true when the commit message contains [ci skip]' do
      request.commit.stubs(:message).returns 'lets party like its 1999 [ci skip]'
      approval.send(:skipped?).should be_true
    end

    it 'returns true when the commit message contains [CI skip]' do
      request.commit.stubs(:message).returns 'lets party like its 1999 [CI skip]'
      approval.send(:skipped?).should be_true
    end

    it 'returns true when the commit message contains [ci:skip]' do
      request.commit.stubs(:message).returns 'lets party like its 1999 [ci:skip]'
      approval.send(:skipped?).should be_true
    end

    it 'returns false when the commit message contains [ci unknown-command]' do
      request.commit.stubs(:message).returns 'lets party like its 1999 [ci unknown-command]'
      approval.send(:skipped?).should be_false
    end
  end

  describe 'github_pages?' do
    it 'returns true for a branch named gh-pages' do
      request.commit.stubs(:ref).returns 'refs/heads/gh-pages'
      approval.send(:github_pages?).should be_true
    end

    it 'returns true for a branch named gh_pages' do
      request.commit.stubs(:ref).returns 'refs/heads/gh_pages'
      approval.send(:github_pages?).should be_true
    end

    it 'returns false for a branch named master' do
      commit.stubs(:ref).returns 'refs/heads/master'
      approval.send(:github_pages?).should be_false
    end
  end

  describe 'blacklisted_repository?' do
    it 'returns true if the repository is a blacklisted repository' do
      request.repository.stubs(:slug).returns 'josh/rails'
      approval.send(:blacklisted_repository?).should be_true
    end

    it 'returns false if the repository is whitelisted repository' do
      request.repository.stubs(:slug).returns 'rails/rails'
      approval.send(:blacklisted_repository?).should be_false
    end

    it 'returns false if the repository is neither blacklisted nor whitelisted' do
      request.repository.stubs(:slug).returns 'josh/completeness-fu'
      approval.send(:blacklisted_repository?).should be_false
    end
  end
end
