require 'spec_helper'

describe Travis::Requests::Services::Receive::Api do
  include Travis::Testing::Stubs

  let(:payload) { Travis::Requests::Services::Receive.payload_for('api', API_PAYLOADS['custom']) }
  let(:slug)    { "#{payload.event['repository']['owner_name']}/#{payload.event['repository']['name']}" }
  let(:repo)    { stub_repo  }

  before :each do
    User.stubs(:find).with(payload.event['user']['id']).returns(user)
    Repository.stubs(:by_slug).with(slug).returns([repo])
  end

  describe 'repository' do
    it 'returns all attributes required for a Repository' do
      payload.repository.should == {
        github_id: repo.github_id
      }
    end
  end

  describe 'owner' do
    it 'returns all attributes required for an Owner' do
      payload.owner.should == {
        type: 'User',
        github_id: 1
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      payload.commit.should == {
        commit: 'b736eea14f5f2094f7c8f7ff902bfaa302c10cbd',
        message: 'Bump to 0.7.3',
        branch: 'master',
        ref: nil,
        committed_at: '2014-05-12T13:27:38Z',
        committer_name: 'Dan Gebhardt',
        committer_email: 'dan@cerebris.com',
        author_name: 'Dan Gebhardt',
        author_email: 'dan@cerebris.com',
        compare_url: nil
      }
    end
  end

  describe 'request' do
    it 'returns attributes for a Request' do
      payload.request.should == {
        config: { 'env' => ['FOO=foo', 'BAR=bar'] },
      }
    end
  end

end
