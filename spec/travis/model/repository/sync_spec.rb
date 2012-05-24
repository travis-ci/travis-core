require 'spec_helper'
require 'support/active_record'

describe Repository::Sync do
  include Support::ActiveRecord

  let(:user) { Factory(:user, :github_oauth_token => 'token' ) }

  subject { lambda { Repository::Sync.new(user).run } }

  before :each do
    GH.stubs(:[]).returns([{ 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true } }])
  end

  it 'fetches all repos the user has access to from the github api' do
    GH.expects(:[]).with('user/repos?per_page=100').returns([])
    subject.call
  end

  it 'creates a new repository per record if not yet present' do
    subject.call
    Repository.find_by_owner_name_and_name('sven', 'minimal').should be_present
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

