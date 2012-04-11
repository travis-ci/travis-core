require 'spec_helper'
require 'support/active_record'
 # && !rails_fork?

describe Request::Approval do
  include Support::ActiveRecord

  let(:request) { Request.new(:commit => Commit.new, :repository => Repository.new) }

  describe 'accept?' do
    it 'accepts a request that has a commit, belongs to a public repository, is not skipped and does not belong to the github_pages branch and it is not a rails fork' do
      request.accept?.should be_true
    end

    it 'does not accept a request that does not have a commit' do
      request.commit = nil
      request.accept?.should be_false
    end

    it 'does not accept a request that belongs to a private repository' do
      request.repository.stubs(:private?).returns(true)
      request.accept?.should be_false
    end

    it 'does not accept a request that belongs to a rails fork' do
      request.repository.stubs(:rails_fork?).returns(true)
      request.accept?.should be_false
    end

    it 'does not accept a request that is skipped (using the commit message)' do
      request.commit.stubs(:skipped?).returns(true)
      request.accept?.should be_false
    end

    it 'does not accept a request that belongs to the github_pages branch' do
      request.commit.stubs(:github_pages?).returns(true)
      request.accept?.should be_false
    end
  end
end
