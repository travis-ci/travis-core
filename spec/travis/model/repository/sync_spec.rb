require 'spec_helper'
require 'support/active_record'

describe Repository::Sync do
  include Support::ActiveRecord

  let(:user) { Factory(:user, :github_oauth_token => 'token' ) }

  subject { lambda { Repository::Sync.new(user).run } }

  it 'fetches all repos the user has access to from the github api' do
    GH.expects(:[]).with('user/repos?per_page=100').returns([])
    subject.call
  end

  it 'creates a new repository per record if not yet present' do
    GH.stubs(:[]).returns([{ 'name' => 'bar', 'owner' => { 'login' => 'foo' }, 'permissions' => { 'admin' => true } }])
    subject.call
    Repository.find_by_owner_name_and_name('foo', 'bar').should be_present
  end
end

