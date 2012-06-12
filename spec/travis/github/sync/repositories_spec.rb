require 'spec_helper'

describe Travis::Github::Sync::Repositories do
  include Support::ActiveRecord

  let(:user) { Factory(:user, :github_oauth_token => 'token' ) }
  let(:repo) { { 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true } } }

  subject { lambda { Travis::Github::Sync::Repositories.new(user).run } }

  before :each do
    Travis::Github.stubs(:repositories_for).returns([repo])
  end

  it 'fetches repos from the github api' do
    Travis::Github.expects(:repositories_for).with(user).returns([repo])
    subject.call
  end

  it 'creates a new repository per record if not yet present' do
    subject.call
    Repository.find_by_owner_name_and_name('sven', 'minimal').should be_present
  end

  it 'does not create a new repository if one exists' do
    Repository.create!(:owner_name => 'sven', :name => 'minimal')
    subject.should_not change(Repository, :count)
  end

  it 'creates a new permission for the user/repo if none exists' do
    subject.should change(Permission, :count).by(1)
  end

  it 'does not create a new permission for the user/repo if one exists' do
    repo = Repository.create(:owner_name => 'sven', :name => 'minimal')
    user.repositories << repo
    subject.should_not change(Permission, :count)
  end
end

