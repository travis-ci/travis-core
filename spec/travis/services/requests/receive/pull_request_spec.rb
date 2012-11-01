require 'spec_helper'

describe Travis::Services::Requests::Receive::PullRequest do
  let(:payload) { Travis::Services::Requests::Receive.payload_for('pull_request', GITHUB_PAYLOADS['pull-request']) }

  describe 'accept' do
    before do
      Travis::Features.enable_for_all(:pull_requests)
    end

    describe 'given action is "opened"' do
      before :each do
        payload.event.data['action'] = 'opened'
      end

      it 'returns true' do
        payload.accept?.should be_true
      end

      it 'rejects it if there is no merge commit' do
        payload.event.data['pull_request']['merge_commit'] = nil
        payload.should_not be_accept
      end

      it "rejects when the feature is disabled" do
        Travis::Features.disable_for_all(:pull_requests)
        payload.accept?.should be_false
      end
    end

    describe 'given action is "reopened"' do
      before :each do
        payload.event.data['action'] = 'reopened'
      end

      it 'returns true' do
        payload.accept?.should be_true
      end
    end

    describe 'given action is "synchronize"' do
      let(:last) { stub('request') }

      before :each do
        payload.event.data['action'] = 'synchronize'
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
        payload.event.data['action'] = 'comment'
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
        :comments_url => 'https://api.github.com/repos/travis-repos/test-project-1/issues/1/comments',
        :base_commit => 'ee644876520685ea3ce144bc8449c1155cee56b4',
        :head_commit => '5442e1772f6de100a2451bd1e08824d3be37a46f'
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      payload.commit.should == {
        :commit => 'ef34a166e2dd7780d40800890474f836c8b3fc34',
        :message => "Merge branch 'master' of git://github.com/travis-repos/test-project-1\n\nConflicts:\n\tRakefile\n",
        :branch => 'master',
        :ref => 'refs/pull/1/merge',
        :committed_at => '2012-04-16T13:30:33Z',
        :committer_name => 'Konstantin Haase',
        :committer_email => 'konstantin.mailinglists@googlemail.com',
        :author_name => 'Konstantin Haase',
        :author_email => 'konstantin.mailinglists@googlemail.com',
        :compare_url => 'https://github.com/travis-repos/test-project-1/pull/1'
      }
    end
  end
end

