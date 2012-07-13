require 'spec_helper'

describe Travis::Github::Sync::Repositories do
  include Travis::Testing::Stubs

  let(:user) { stub_user(:organizations => [org], :github_oauth_token => 'token') }
  let(:org)  { stub('org', :login => 'the-org') }
  let(:repo) { stub('repo', :run => stub_repository) }
  let(:sync) { Travis::Github::Sync::Repositories.new(user) }

  let(:repos) { [
    { 'name' => 'public',  'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => false },
    { 'name' => 'private', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true }, 'private' => true }
  ]}

  before :each do
    GH.stubs(:[]).returns(repos)
    Travis::Github::Sync::Repository.stubs(:new).returns(repo)
    @type = Travis::Github::Sync::Repositories.type
  end

  after :each do
    Travis::Github::Sync::Repositories.type = @type
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
      Travis::Github::Sync::Repositories.type = 'public'
    end

    it 'synchronizes each of the public repositories' do
      Travis::Github::Sync::Repository.expects(:new).with(user, repos.first).once.returns(repo)
      sync.run
    end

    it 'does not synchronize private repositories' do
      Travis::Github::Sync::Repository.expects(:new).with(user, repos.last).never
      sync.run
    end
  end
end
