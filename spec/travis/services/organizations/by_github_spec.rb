require 'spec_helper'

describe Travis::Services::Organizations::ByGithub do
  include Travis::Testing::Stubs

  let(:service) { Travis::Services::Organizations::ByGithub.new(nil, {}) }

  before :each do
  end

  describe 'run' do
    it 'finds an existing organization' do
    end

    it 'creates an organization from github' do
    end

    it 'raises a GithubApi error if the organization could not be retrieved' do
    end
  end
end
