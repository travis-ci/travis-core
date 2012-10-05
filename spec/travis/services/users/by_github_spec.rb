require 'spec_helper'

describe Travis::Services::Users::ByGithub do
  include Travis::Testing::Stubs

  let(:service) { Travis::Services::Users::ByGithub.new(nil, {}) }

  before :each do
  end

  it 'finds an existing user' do
  end

  it 'creates an user from github' do
  end

  it 'raises a GithubApi error if the user could not be retrieved' do
  end
end
