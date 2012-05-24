require 'spec_helper'

describe Travis::Github::Repositories do
  let(:org)  { stub('org', :login => 'the-org') }
  let(:user) { stub('user', :organizations => [org], :github_oauth_token => 'token') }

  before :each do
    GH.stubs(:[]).returns([{ 'name' => 'repo' }])
  end

  subject do
    Travis::Github::Repositories.new(user).fetch
  end

  it "fetches the user's repositories" do
    GH.expects(:[]).with('user/repos?type=public')
    subject
  end

  it "fetches the user's orgs' repositories" do
    GH.expects(:[]).with('orgs/the-org/repos?type=public')
    subject
  end

  it "returns an array of payloads returned by GH" do
    subject.should == [ { 'name' => 'repo' }, { 'name' => 'repo' } ]
  end
end
