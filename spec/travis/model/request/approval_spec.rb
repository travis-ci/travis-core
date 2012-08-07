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

    it 'does not accept a request that belongs to a rails fork' do
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

  describe 'rails_fork?' do
    it 'returns true if the repository is a rails fork' do
      request.repository.stubs(:slug).returns 'josh/rails'
      approval.send(:rails_fork?).should be_true
    end

    it 'returns false if the repository is rails/rails' do
      request.repository.stubs(:slug).returns 'rails/rails'
      approval.send(:rails_fork?).should be_false
    end

    it 'returns false if the repository is not owned by the rails org' do
      request.repository.stubs(:slug).returns 'josh/completeness-fu'
      approval.send(:rails_fork?).should be_false
    end
  end

  describe 'pull_request_allowed?' do
    it 'accepts push events' do
      approval.should be_pull_request_allowed
    end

    it 'accepts pull request events' do
      request.stubs(:pull_request?).returns(true)
      approval.should be_pull_request_allowed
    end

    # it 'rejects pull request events' do
    #   request.stubs(:pull_request?).returns(true)
    #   approval.should_not be_pull_request_allowed
    # end
    # 
    # it 'accepts pull request events if pull request testing has been enabled' do
    #   request.stubs(:pull_request?).returns(true)
    #   request.config['addons'] = 'pull_requests'
    #   approval.should be_pull_request_allowed
    # end
  end
end
