require 'spec_helper'

describe Travis::Requests::Services::Receive::Cron do
  include Travis::Testing::Stubs

  let(:payload) { API_PAYLOADS['custom'].dup }
  let(:slug)    { "#{payload['repository']['owner_name']}/#{payload['repository']['name']}" }
  let(:repo)    { stub_repo  }
  subject       { Travis::Requests::Services::Receive.payload_for('cron', payload) }

  before :each do
    User.stubs(:find).with(payload['user']['id']).returns(user)
    Repository.stubs(:by_slug).with(slug).returns([repo])
  end

  describe 'repository' do
    it 'returns all attributes required for a Repository' do
      subject.repository.should == {
        name: 'gem-release',
        owner_id: 2208,
        owner_type: 'User',
        owner_name: 'svenfuchs'
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      subject.commit.should == {
        commit: 'b736eea14f5f2094f7c8f7ff902bfaa302c10cbd',
        message: 'Bump to 0.7.3',
        branch: 'master',
        ref: nil,
        committed_at: '2014-05-12T13:27:38Z',
        committer_name: 'Dan Gebhardt',
        committer_email: 'dan@cerebris.com',
        author_name: 'Dan Gebhardt',
        author_email: 'dan@cerebris.com',
        compare_url: 'https://api.github.com/repos/svenfuchs/gem-release/commits/b736eea14f5f2094f7c8f7ff902bfaa302c10cbd'
      }
    end
  end

  describe 'request' do
    it 'returns attributes for a Request' do
      subject.request.should == {
        config: { 'env' => ['FOO=foo', 'BAR=bar'] },
      }
    end
  end

  it 'uses a custom message if given' do
    payload['message'] = 'custom message'
    subject.commit[:message].should == 'custom message'
  end
end
