require 'spec_helper'

describe Travis::Github::Payload::PullRequest do
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

    describe 'given action is "reopened"' do
      before :each do
        payload.gh.data['action'] = 'reopened'
      end

      it 'returns true' do
        payload.accept?.should be_true
      end
    end

    describe 'given action is "synchronize"' do
      let(:last) { stub('request') }

      before :each do
        payload.gh.data['action'] = 'synchronize'
      end

      it 'returns true if head has changed' do
        Request.stubs(:last_by_head_commit).returns(nil)
        payload.accept?.should be_true
      end

      it 'returns false if base has not changed' do
        Request.stubs(:last_by_head_commit).returns(last)
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
        :comments_url => 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments',
        :head_commit => '1317692c01d0c3a20b89ea634d06cd66b8c517d3'
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      payload.commit.should == {
        :commit => 'dc7423310796301fe71b98eda8b5ba1afee3f639',
        :message => "do not require rake\n",
        :branch => 'master',
        :ref => 'refs/pull/1/merge',
        :committed_at => '2012-04-14T16:19:15Z',
        :committer_name => 'Konstantin Haase',
        :committer_email => 'konstantin.mailinglists@googlemail.com',
        :author_name => 'Konstantin Haase',
        :author_email => 'konstantin.mailinglists@googlemail.com',
        :compare_url => 'https://github.com/travis-repos/test-project-1/pull/1'
      }
    end
  end
end
