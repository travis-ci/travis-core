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

  describe 'pull_request_title' do
    it 'returns the title of the pull request from payload' do
      request.event_type = 'pull_request'
      request.payload = { 'pull_request' => { 'title' => 'A pull request' } }

      request.pull_request_title.should == 'A pull request'
    end

    it 'returns nil for non pull request' do
      request.event_type = 'build'
      request.payload = { 'pull_request' => { 'title' => 'A pull request' } }

      request.pull_request_title.should be_nil
    end
  end

  describe 'tag_name' do
    it 'returns a tag name if available' do
      request.payload = { 'ref' => 'refs/tags/foo' }

      request.tag_name.should == 'foo'
    end

    it 'returns nil if a tag name is not available' do
      request.payload = { 'ref' => 'refs/heads/foo' }

      request.tag_name.should be_nil
    end
  end

  describe 'branch_name' do
    it 'returns a branch name if available' do
      request.payload = { 'ref' => 'refs/heads/foo' }

      request.branch_name.should == 'foo'
    end

    it 'returns nil if a branch name is not available' do
      request.payload = { 'ref' => 'refs/tags/foo' }

      request.branch_name.should be_nil
    end
  end

  describe 'pull_request_author_has_permissions?' do
    it 'returns false without an author id' do
      request.payload = {
        'pull_request' => {
          'user' => {
            'id' => nil
          }
        }
      }

      request.pull_request_author_has_permissions?.should be_false
    end

    it 'returns false without an author in our DB' do
      request.payload = {
        'pull_request' => {
          'user' => {
            'id' => 0
          }
        }
      }

      request.pull_request_author_has_permissions?.should be_false
    end

    it 'returns false without proper permission' do
      user = Factory(:user, github_id: 100)
      repo = Factory(:repository)
      repo.permissions.destroy_all
      repo.permissions.create!(repository_id: repo.id, pull: true)

      request.payload = {
        'pull_request' => {
          'user' => {
            'id' => user.github_id
          }
        }
      }

      request.pull_request_author_has_permissions?.should be_false
    end

    it 'returns true with a user and permissions' do
      user = Factory(:user, github_id: 100)
      user.permissions.destroy_all
      user.permissions.create!(repository_id: repo.id, push: true, pull: true)

      request.payload = {
        'pull_request' => {
          'user' => {
            'id' => user.github_id
          }
        }
      }

      request.pull_request_author_has_permissions?.should be_true
    end
  end

  describe 'same_repo_pull_request?' do
    it 'returns true if the base and head repos match' do
      request.payload = {
        'pull_request' => {
          'base' => { 'repo' => { 'full_name' => 'travis-ci/travis-core' } },
          'head' => { 'repo' => { 'full_name' => 'travis-ci/travis-core' } }
        }
      }

      request.same_repo_pull_request?.should be_true
    end

    it 'returns false if the base and head repos do not match' do
      request.payload = {
        'pull_request' => {
          'base' => { 'repo' => { 'full_name' => 'travis-ci/travis-core' } },
          'head' => { 'repo' => { 'full_name' => 'evilmonkey/travis-core' } }
        }
      }

      request.same_repo_pull_request?.should be_false
    end

    it 'returns false if repo data is not available' do
      request.payload = {}

      request.same_repo_pull_request?.should be_false
    end
  end
end
