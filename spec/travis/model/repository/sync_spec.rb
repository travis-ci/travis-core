require 'spec_helper'
require 'support/active_record'

describe Repository::Sync do
  include Support::ActiveRecord

  let(:user) { Factory(:user, :github_oauth_token => 'token' ) }

  subject { lambda { Repository::Sync.new(user).run } }

  before :each do
    GH.stubs(:[]).returns([{ 'name' => 'minimal', 'owner' => { 'login' => 'sven' }, 'permissions' => { 'admin' => true } }])
    @type = Travis::Github::Repositories.type
  end

  after :each do
    Travis::Github::Repositories.type = @type
  end

  describe 'fetches repos from the github api' do
    it 'using "public" as a type by default' do
      GH.expects(:[]).with('user/repos?type=public').returns([])
      subject.call
    end

    it 'using a custom type if set' do
      Travis::Github::Repositories.type = 'private'
      GH.expects(:[]).with('user/repos?type=private').returns([])
      subject.call
    end
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

