require 'spec_helper'
require 'support/webmock'

describe Travis::Github::Payload::PullRequest do
  include Support::Webmock

  let(:payload) { Travis::Github::Payload.for('pull_request', GITHUB_PAYLOADS['pull-request']) }

  describe 'accept' do
    describe 'given action is "opened"' do
      before :each do
        payload.gh.data['action'] = 'opened'
      end

      it 'returns true' do
        payload.accept?.should be_true
      end
    end

    describe 'given action is "synchronize"' do
      let(:last) { stub('commit') }

      before :each do
        payload.gh.data['action'] = 'synchronize'
        Commit.stubs(:last_by_comments_url).returns(last)
      end

      it 'returns true if head has changed' do
        last.stubs(:commit).returns('12345')
        payload.accept?.should be_true
      end

      it 'returns false if base has not changed' do
        last.stubs(:commit).returns(payload.head_commit['sha'])
        payload.accept?.should be_false
      end
    end

    describe 'given action is "comment"' do
      before :each do
        payload.gh.data['action'] = 'comment'
      end

      it 'returns false' do
        payload.accept?.should be_false
      end
    end
  end

  describe 'repository' do
    it 'returns all attributes required for a Repository' do
      payload.repository.should == {
        :name => 'test-project-1',
        :description => 'Test dummy repository for testing Travis CI',
        :url => 'https://github.com/travis-repos/test-project-1',
        :owner_type => 'Organization',
        :owner_name => 'travis-repos',
        :owner_email => nil,
        :private => false
      }
    end
  end

  describe 'owner' do
    it 'returns all attributes required for an Owner' do
      payload.owner.should == {
        :type => 'Organization',
        :login => 'travis-repos'
      }
    end
  end

  describe 'request' do
    it 'returns all attributes required for a Request' do
      payload.request.should == {
        :payload => GITHUB_PAYLOADS['pull-request'],
        :comments_url => 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments'
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      payload.commit.should == {
        :commit => '77ca44550e92e9292f58150a0f9c11e9a0dac922',
        :message => 'Update README.md',
        :branch => 'master',
        :ref => 'refs/pull/1/merge',
        :committed_at => '2012-02-14T14:00:25Z',
        :committer_name => 'Konstantin Haase',
        :committer_email => 'k.haase@finn.de',
        :author_name => 'Konstantin Haase',
        :author_email => 'k.haase@finn.de',
        :compare_url => 'https://github.com/travis-repos/test-project-1/pull/1'
      }
    end
  end
end
