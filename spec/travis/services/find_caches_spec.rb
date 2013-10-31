require 'spec_helper'

describe Travis::Services::FindCaches do
  include Support::ActiveRecord, Support::S3

  let(:user) { User.first || Factory(:user) }
  let(:service) { described_class.new(user, params) }
  let(:repo) { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let(:result) { service.run }
  let(:has_access) { true }
  subject { result }

  before :each do
    Travis.config.roles = {}
    Travis.config.cache_options = { s3: { bucket_name: '' } }
    user.stubs(:permission?).returns(has_access)
  end

  describe 'given a repository_id' do
    let(:params) {{ repository_id: repo.id }}

    describe 'without any caches' do
      it { should be == [] }
    end

    describe 'with caches' do
      before do
        s3_bucket << "#{repo.github_id}/master/cache--example1.tbz"
        s3_bucket << "#{repo.github_id}/other/cache--example2.tbz"
        s3_bucket << "#{repo.github_id.succ}/master/cache--example3.tbz"
      end

      its(:size) { should be == 2 }

      describe 'the cache instances' do
        subject { result.first }
        its(:slug)       { should be == 'cache--example1' }
        its(:branch)     { should be == 'master' }
        its(:repository) { should be == repo }
        its(:size)       { should be == 0 }
      end

      describe 'with branch' do
        let(:params) {{ repository_id: repo.id, branch: 'other' }}
        its(:size) { should be == 1 }
      end

      describe 'with match' do
        let(:params) {{ repository_id: repo.id, match: 'example1' }}
        its(:size) { should be == 1 }
      end

      describe 'without access' do
        let(:has_access) { false }
        its(:size) { should be == 0 }
      end
    end
  end
end