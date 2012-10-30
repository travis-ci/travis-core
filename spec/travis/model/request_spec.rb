require 'spec_helper'

describe Request do
  include Support::ActiveRecord

  let(:repo)    { Repository.new(owner_name: 'travis-ci', name: 'travis-ci') }
  let(:commit)  { Commit.new(commit: '12345678') }
  let(:request) { Request.new(repository: repo, commit: commit) }

  describe 'config_url' do
    it 'returns the raw url to the .travis.yml file on github' do
      request.config_url.should == 'https://api.github.com/repos/travis-ci/travis-ci/contents/.travis.yml?ref=12345678'
    end
  end
end
