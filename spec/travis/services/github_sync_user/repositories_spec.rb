require 'spec_helper'

describe Travis::Services::GithubSyncUser::Repositories do
  include Travis::Testing::Stubs

  let(:repository)   { Travis::Services::GithubSyncUser::Repository }

  let(:public_repo)  { stub_repository(:slug => 'sven/public')  }
  let(:private_repo) { stub_repository(:slug => 'sven/private') }
  let(:removed_repo) { stub_repository(:slug => 'sven/removed') }

  let(:user) { stub_user(:organizations => [org], :github_oauth_token => 'token', :repositories => [public_repo, removed_repo]) }
  let(:org)  { stub('org', :login => 'the-org') }
  let(:sync) { described_class.new(user) }

  let(:repos) { [
    { 'name' => 'public',  'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false },
    { 'name' => 'private', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => true }
  ] }

  before :each do
    GH.stubs(:[]).returns(repos)
    repository.stubs(:new).returns(stub('repo', :run => public_repo))
    repository.stubs(:unpermit_all)
    @type = described_class.type
  end

  after :each do
    described_class.type = @type
  end

  it "fetches the user's repositories" do
    GH.expects(:[]).with('user/repos') # should be: ?type=public
    sync.run
  end

  it "fetches the user's orgs' repositories" do
    GH.expects(:[]).with('orgs/the-org/repos') # should be: ?type=public
    sync.run
  end

  describe 'given type is set to public' do
    before :each do
      described_class.type = 'public'
    end

    it 'synchronizes each of the public repositories' do
      repository.expects(:new).with(user, repos.first).once.returns(stub('repo', :run => public_repo))
      sync.run
    end

    it 'does not synchronize private repositories' do
      repository.expects(:new).with(user, repos.last).never
      sync.run
    end
  end

  describe 'given type is set to private' do
    before :each do
      described_class.type = 'private'
    end

    it 'synchronizes each of the private repositories' do
      repository.expects(:new).with(user, repos.last).once.returns(stub('repo', :run => private_repo))
      sync.run
    end

    it 'does not synchronize public repositories' do
      repository.expects(:new).with(user, repos.first).never
      sync.run
    end
  end

  it "removes repositories from the user's permissions which are not listed in the data from github" do
    repository.expects(:unpermit_all).with(user, [removed_repo])
    sync.run
  end

  context "with private forks of organization repositories" do
    let(:user_repositories) {[
      { 'name' => 'public',  'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false },
      { 'name' => 'private', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => true, 'fork' => true}
    ]}
    let(:duplicate_org_repositories) {[
      { 'name' => 'private', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => false }, 'private' => true, 'fork' => true}
    ]}
    let(:org_repositories) {[
      { 'name' => 'other', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => false }, 'private' => true, 'fork' => true}
    ]}
    let(:order) {sequence('github-sync')}

    before do
      described_class.type = 'private'
      repository.unstub(:new)
    end

    it "should not sync the organization's duplicate" do
      repository.expects(:new).once.returns(stub('repository', :run => public_repo))
      GH.expects(:[]).with('user/repos').returns(user_repositories).in_sequence(order)
      GH.expects(:[]).with('orgs/the-org/repos').returns(duplicate_org_repositories).in_sequence(order)
      sync.run
    end

    it "should sync the organization's repository when it's not a duplicate" do
      repository.expects(:new).twice.returns(stub('repository', :run => public_repo))
      GH.expects(:[]).with('user/repos').returns(user_repositories).in_sequence(order)
      GH.expects(:[]).with('orgs/the-org/repos').returns(org_repositories).in_sequence(order)
      sync.run
    end

    it "should sync the organization's repository when it has admin rights" do
      # this is an unlikely scenario, but as the code checks for it, a test is in order
      repository.expects(:new).twice.returns(stub('repository', :run => public_repo))
      GH.expects(:[]).with('user/repos').returns(duplicate_org_repositories).in_sequence(order)
      GH.expects(:[]).with('orgs/the-org/repos').returns(user_repositories).in_sequence(order)
      sync.run
    end
  end
end

describe Travis::Services::GithubSyncUser::Repositories::Instrument do
  include Support::ActiveRecord

  let(:service)   { Travis::Services::GithubSyncUser::Repositories.new(user) }
  let(:publisher) { Travis::Notification::Publisher::Memory.new }
  let(:events)    { publisher.events }

  let(:user)      { Factory(:user, login: 'sven', github_oauth_token: '123456') }
  let(:data)      { [{ 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false }] }

  before :each do
    Travis::Notification.publishers.replace([publisher])
    GH.stubs(:[]).returns(data)
    service.run
  end

  it 'publishes a event on :run' do
    events[3].should publish_instrumentation_event(
      event: 'travis.services.github_sync_user.repositories.run:completed',
      message: %(Travis::Services::GithubSyncUser::Repositories#run:completed for #<User id=#{user.id} login="sven">),
      result: {
        synced: [{ id: Repository.last.id, owner: 'sven', name: 'minimal' }],
        removed: []
      },
      data: {
        resources: ['user/repos'],
      }
    )
  end

  it 'publishes a event on :fetch' do
    events[2].should publish_instrumentation_event(
      event: 'travis.services.github_sync_user.repositories.fetch:completed',
      message: %(Travis::Services::GithubSyncUser::Repositories#fetch:completed for #<User id=#{user.id} login="sven">),
      result: data,
      data: {
        resources: ['user/repos'],
      }
    )
  end
end
