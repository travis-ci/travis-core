require 'spec_helper'

describe Travis::Github::Repositories do
  include Travis::Testing::Stubs

  let(:org)  { stub('org', :login => 'the-org') }
  let(:user) { stub_user(:organizations => [org]) }

  before :each do
    GH.stubs(:[]).returns([
      { 'name' => 'public', 'private' => false },
      { 'name' => 'private', 'private' => true }
    ])
    @type = Travis::Github::Repositories.type
  end

  after :each do
    Travis::Github::Repositories.type = @type
  end

  subject do
    Travis::Github::Repositories.new(user).fetch
  end

  it "fetches the user's repositories" do
    GH.expects(:[]).with('user/repos') # should be: ?type=public
    subject
  end

  it "fetches the user's orgs' repositories" do
    GH.expects(:[]).with('orgs/the-org/repos') # should be: ?type=public
    subject
  end

  it "returns an array of public repository payloads by default" do
    subject.map { |repo| repo['name'] }.should == ['public', 'public']
  end

  it "returns an array of private repository payloads if type was set to 'private'" do
    Travis::Github::Repositories.type = 'private'
    subject.map { |repo| repo['name'] }.should == ['private', 'private']
  end
end
