require 'spec_helper'

describe Travis::Github::Services::SyncUser::Organizations do
  include Support::ActiveRecord

  describe 'run' do
    let(:user)    { Factory(:user, :login => 'sven', :github_oauth_token => '123456') }
    let(:action)  { lambda { described_class.new(user).run } }
    let(:data)    { [{ 'id' => 1, 'login' => 'small' }] }

    before :each do
      GH.stubs(:[]).with('user/orgs').returns(data)
      GH.stubs(:[]).with('organizations/1').returns({
        "id" => 1,
        "name" => "MEGA ORG",
        "company" => "Mega Org GmbH",
        "location" => "Berlin",
        "email" => "mega@org.com",
        "login" => "mega",
        "_links" => {
          "avatar" => { "href" => "https://secure.gravatar.com/avatar/253768044712357787be0f6a3a53cc66?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png" },
          "blog" => { "href" => "http://travis-ci.org" }
        }
      })
    end

    describe 'with organization with repos over limit' do
      before do
        GH.expects(:[]).with('organizations/2').returns('public_repositories' => 11)
        @old_optons = Travis.config.sync.organizations
        Travis.config.sync.organizations = { :repositories_limit => 10 }
      end

      after do
        Travis.config.sync.organizations = @old_options
      end

      let(:data) { [{ 'id' => 2, 'login' => 'FooBar' }] }

      it 'does not create organization matching "exclude" list' do
        action.should_not change(Organization, :count)
      end
    end

    describe 'creates missing organizations' do
      it 'creates missing organizations' do
        action.should change(Organization, :count).by(1)
      end

      it 'makes the user a member of the organization' do
        action.call
        user.reload.organizations.should include(Organization.first)
      end
    end

    describe 'updates existing organizations' do
      it 'does not create a new organization' do
        Organization.create!(:github_id => 1)
        action.should_not change(Organization, :count)
      end

      it 'updates the organization attributes' do
        org = Organization.create!(:github_id => 1, :login => 'small')
        action.call
        org.reload.login.should == 'mega'
      end

      it 'makes the user a member of the organization' do
        action.call
        user.organizations.should include(Organization.first)
      end
    end

    it 'removes stale organization memberships' do
      user.organizations << Organization.create!(:github_id => 1)
      action.call
      user.organizations.should include(Organization.first)
    end
  end
end

describe Travis::Github::Services::SyncUser::Organizations::Instrument do
  include Support::ActiveRecord

  let(:service)   { Travis::Github::Services::SyncUser::Organizations.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }

  let(:travis)    { Organization.find_by_login('travis-ci') }
  let(:sinatra)   { Organization.find_by_login('sinatra') }

  let(:user)      { Factory(:user, login: 'sven', github_oauth_token: '123456') }
  let(:data)      { [ { 'id' => 1, 'name' => 'Travis CI', 'login' => 'travis-ci' }, { 'id' => 2, 'name' => 'Sinatra', 'login' => 'sinatra' } ] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).with('user/orgs').returns data
    GH.stubs(:[]).with('organizations/1').returns({
      "id" => 1,
      "name" => "Travis CI",
      "company" => "Travis CI GmbH",
      "location" => "Berlin",
      "email" => "contact@travis-ci.org",
      "login" => "travis-ci",
      "_links" => {
        "avatar" => { "href" => "https://secure.gravatar.com/avatar/253768044712357787be0f6a3a53cc66?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png" },
        "blog" => { "href" => "http://travis-ci.org" }
      }
    })
    GH.stubs(:[]).with('organizations/2').returns({
      "id" => 2,
      "name" => "Sinatra",
      "company" => nil,
      "location" => nil,
      "email" => nil,
      "login" => "sinatra",
      "_links" => {
        "avatar" => { "href" => "https://secure.gravatar.com/avatar/253768044712357787be0f6a3a53cc66?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png" },
        "blog" => { "href" => "http://sinatra.org" }
      }
    })
    service.run
  end

  it 'publishes a event on :run' do
    events[3].should publish_instrumentation_event(
      event: 'travis.github.services.sync_user.organizations.run:completed',
      message: %(Travis::Github::Services::SyncUser::Organizations#run:completed for #<User id=#{user.id} login="sven">),
      result: {
        synced: [{ id: travis.id, login: 'travis-ci' }, { id: sinatra.id, login: 'sinatra' }],
        removed: []
      }
    )
  end

  it 'publishes a event on :fetch' do
    events[2].should publish_instrumentation_event(
      event: 'travis.github.services.sync_user.organizations.fetch:completed',
      message: %(Travis::Github::Services::SyncUser::Organizations#fetch:completed for #<User id=#{user.id} login="sven">),
      result: data
    )
  end
end

