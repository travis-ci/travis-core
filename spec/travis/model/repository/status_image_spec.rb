require 'spec_helper'

describe Repository::StatusImage do
  include Support::ActiveRecord

  let(:cache)    { stub('states cache', fetch: nil, write: nil, fetch_state: nil) }
  let!(:request) { Factory(:request, event_type: 'push', repository: repo) }
  let!(:build)   { Factory(:build, repository: repo, request: request, state: :passed) }
  let(:repo)     { Factory(:repository) }

  before do
    described_class.any_instance.stubs(cache: cache)
  end

  describe('with cache') do
    it 'tries to get state from cache first' do
      image = described_class.new(repo, 'foobar')
      cache.expects(:fetch_state).with(repo.id, 'foobar').returns(:passed)

      image.result.should == :passing
    end

    it 'saves state to the cache if it needs to be fetched from the db' do
      image = described_class.new(repo, 'master')
      cache.expects(:fetch_state).with(repo.id, 'master').returns(nil)
      cache.expects(:write).with(repo.id, 'master', build)

      image.result.should == :passing
    end

    it 'saves state of the build to the cache with its branch even if brianch is not given' do
      image = described_class.new(repo, nil)
      cache.expects(:fetch_state).with(repo.id, nil).returns(nil)
      cache.expects(:write).with(repo.id, 'master', build)

      image.result.should == :passing
    end
  end

  describe 'given no branch' do
    it 'returns the status of the last finished build' do
      image = described_class.new(repo, nil)
      image.result.should == :passing
    end

    it 'returns :failing if the status of the last finished build is failed' do
      build.update_attributes(state: :failed)
      image = described_class.new(repo, nil)
      image.result.should == :failing
    end

    it 'returns :error if the status of the last finished build is errored' do
      build.update_attributes(state: :errored)
      image = described_class.new(repo, nil)
      image.result.should == :error
    end

    it 'returns :unknown if the status of the last finished build is unknown' do
      build.update_attributes(state: :created)
      image = described_class.new(repo, nil)
      image.result.should == :unknown
    end
  end

  describe 'given a branch' do
    it 'returns :passed if the last build on that branch has passed' do
      build.update_attributes(state: :passed, branch: 'master')
      image = described_class.new(repo, 'master')
      image.result.should == :passing
    end

    it 'returns :failed if the last build on that branch has failed' do
      build.update_attributes(state: :failed, branch: 'develop')
      image = described_class.new(repo, 'develop')
      image.result.should == :failing
    end

    it 'returns :error if the last build on that branch has errored' do
      build.update_attributes(state: :errored, branch: 'develop')
      image = described_class.new(repo, 'develop')
      image.result.should == :error
    end
  end
end
