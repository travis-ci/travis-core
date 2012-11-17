require 'spec_helper'

describe Travis::Github::Services::FindOrCreateOrg do
  include Travis::Testing::Stubs

  let(:service) { described_class.new(nil, {}) }

  before :each do
  end

  xit 'finds an existing organization' do
  end

  xit 'creates an organization from github' do
  end

  xit 'raises a GithubApi error if the organization could not be retrieved' do
  end
end
