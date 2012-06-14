require 'spec_helper'

describe User do
  include Support::ActiveRecord

  let(:user)    { Factory(:user, :github_oauth_token => 'token') }
  let(:payload) { GITHUB_PAYLOADS[:oauth] }

  describe 'find_or_create_for_oauth' do
    def user(payload)
      User.find_or_create_for_oauth(payload)
    end

    it 'marks new users as such' do
      user(payload).should be_recently_signed_up
      user(payload).should_not be_recently_signed_up
    end

    it 'updates changed attributes' do
      user(payload).attributes.slice(*GITHUB_OAUTH_DATA.keys).should == GITHUB_OAUTH_DATA
    end
  end

  describe 'organization_ids' do
    let!(:travis)  { Factory(:org, :login => 'travis') }
    let!(:sinatra) { Factory(:org, :login => 'sinatra') }

    before :each do
     user.organizations << travis
     user.save!
    end

    it 'contains the ids of organizations that the user is a member of' do
      user.organization_ids.should include(travis.id)
    end

    it 'does not contain the ids of organizations that the user is not a member of' do
      user.organization_ids.should_not include(sinatra.id)
    end
  end

  describe 'repository_ids' do
    let!(:travis)  { Factory(:repository, :name => 'travis', :owner => Factory(:org, :name => 'travis')) }
    let!(:sinatra) { Factory(:repository, :name => 'sinatra', :owner => Factory(:org, :name => 'sinatra')) }

    before :each do
     user.repositories << travis
     user.save!
     user.reload
    end

    it 'contains the ids of repositories the user is permitted to see' do
      user.repository_ids.should include(travis.id)
    end

    it 'does not contain the ids of repositories the user is not permitted to see' do
      user.repository_ids.should_not include(sinatra.id)
    end
  end

  describe 'profile_image_hash' do
    it "returns gravatar_id if it's present" do
      user.gravatar_id = '41193cdbffbf06be0cdf231b28c54b18'
      user.profile_image_hash.should == '41193cdbffbf06be0cdf231b28c54b18'
    end

    it 'returns a MD5 hash of the email if no gravatar_id and an email is set' do
      user.gravatar_id = nil
      user.profile_image_hash.should == Digest::MD5.hexdigest(user.email)
    end

    it 'returns 32 zeros if no gravatar_id or email is set' do
      user.gravatar_id = nil
      user.email = nil
      user.profile_image_hash.should == '0' * 32
    end
  end

  describe 'authenticated_on_github' do
    let(:user) { User.find_or_create_for_oauth(payload) }

    before do
      WebMock.stub_request(:get, 'https://api.github.com/user').
        with(:headers => {'Authorization' => "token #{payload['credentials']['token']}"}).
        to_return(:status => 200, :body => payload.to_json, :headers => {})
    end

    it 'should log the user in' do
      user.authenticated_on_github do
        GH['/user']['name'].should be == payload['name']
      end
    end
  end

  describe 'authenticate_by' do
    describe 'given a valid token and login' do
      it 'authenticates the user' do
        User.authenticate_by('login' => user.login, 'token' => user.tokens.first.token).should == user
      end
    end

    describe 'given a wrong token' do
      it 'does not authenticate the user' do
        User.authenticate_by('login' => 'someone-else', 'token' => user.tokens.first.token).should be_nil
      end
    end

    describe 'given a wrong login' do
      it 'does not authenticate the user' do
        User.authenticate_by('login' => user.login, 'token' => 'some-other-token').should be_nil
      end
    end
  end

  describe 'service_hooks' do
    let(:own_repo)   { Factory(:repository, :name => 'own-repo', :description => 'description', :active => true) }
    let(:admin_repo) { Factory(:repository, :name => 'admin-repo') }
    let(:other_repo) { Factory(:repository, :name => 'other-repo') }

    before :each do
      user.permissions.create! :user => user, :repository => own_repo, :admin => true
      user.permissions.create! :user => user, :repository => admin_repo, :admin => true
      other_repo
    end

    it "contains repositories where the user has an admin role" do
      service_hook = user.service_hooks.last
      service_hook.uid.should == 'svenfuchs:own-repo'
      service_hook.owner_name.should == 'svenfuchs'
      service_hook.name.should == 'own-repo'
      service_hook.description.should == 'description'
      service_hook.url.should == 'https://github.com/svenfuchs/own-repo'
      service_hook.active.should be_true
    end

    it "does not contain repositories where the user does not have an admin role" do
      service_hooks = user.service_hooks
      service_hooks.any? { |s| s.name == 'other-repo' }.should be_false
    end
  end
end
