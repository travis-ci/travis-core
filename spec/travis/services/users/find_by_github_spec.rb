require 'spec_helper'

describe Travis::Services::Users::FindByGithub do
  include Travis::Testing::Stubs

  let(:service) { Travis::Services::Users::FindByGithub.new(nil, {}) }

  before :each do
  end

  xit 'finds an existing user' do
  end

  xit 'creates an user from github' do
  end

  xit 'raises a GithubApi error if the user could not be retrieved' do
  end
end
