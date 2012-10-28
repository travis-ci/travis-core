require 'spec_helper'

describe Travis::Services::Github::SyncUser::Repositories do
  include Travis::Testing::Stubs

  let(:subject)      { Travis::Services::Github::SyncUser::Repositories }
  let(:repository)   { Travis::Services::Github::SyncUser::Repository }

  let(:public_repo)  { stub_repository(:slug => 'sven/public')  }
  let(:private_repo) { stub_repository(:slug => 'sven/private') }
  let(:removed_repo) { stub_repository(:slug => 'sven/removed') }

  let(:user) { stub_user(:organizations => [org], :github_oauth_token => 'token', :repositories => [public_repo, removed_repo]) }
  let(:org)  { stub('org', :login => 'the-org') }
  let(:sync) { subject.new(user) }

  let(:repos) { [
    { 'name' => 'public',  'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false },
    { 'name' => 'private', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => true }
  ] }

  before :each do
    GH.stubs(:[]).returns(repos)
    repository.stubs(:new).returns(stub('repo', :run => public_repo))
    repository.stubs(:unpermit_all)
    @type = subject.type
  end

  after :each do
    subject.type = @type
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
      subject.type = 'public'
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
      subject.type = 'private'
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
      subject.type = 'private'
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
