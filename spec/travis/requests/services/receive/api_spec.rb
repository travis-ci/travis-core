require 'spec_helper'

describe Travis::Requests::Services::Receive::Api do
  include Travis::Testing::Stubs

  let(:payload) { Travis::Requests::Services::Receive.payload_for('api', API_PAYLOADS['custom']) }

  before :each do
    User.stubs(:find).with(payload.event['user']['id']).returns(user)
  end

  describe 'repository' do
    it 'returns all attributes required for a Repository' do
      payload.repository.should == {
        :name => 'gem-release',
        :description => 'Release your ruby gems with ease. (What a bold statement for such a tiny plugin ...)',
        :url => 'https://github.com/svenfuchs/gem-release',
        :owner_name => 'svenfuchs',
        :owner_email => 'me@svenfuchs.com',
        :owner_type => 'User',
        :private => false,
        :github_id => 592533
      }
    end
  end

  describe 'owner' do
    it 'returns all attributes required for an Owner' do
      payload.owner.should == {
        :type => 'User',
        :login => 'svenfuchs',
        :github_id => nil # TODO I guess this is fine because we should never create this user?
      }
    end
  end

  describe 'commit' do
    it 'returns all attributes required for a Commit' do
      payload.commit.should == {
        :commit => 'b736eea14f5f2094f7c8f7ff902bfaa302c10cbd',
        :message => 'Bump to 0.7.3',
        :branch => 'master',
        :ref => nil,
        :committed_at => '2014-05-12T13:27:38Z',
        :committer_name => 'Dan Gebhardt',
        :committer_email => 'dan@cerebris.com',
        :author_name => 'Dan Gebhardt',
        :author_email => 'dan@cerebris.com',
        :compare_url => nil
      }
    end
  end

  describe 'request' do
    it 'returns attributes for a Request' do
      payload.request.should == {
        :config => { 'env' => ['FOO=foo', 'BAR=bar'] },
      }
    end
  end

end
