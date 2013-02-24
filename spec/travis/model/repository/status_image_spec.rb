require 'spec_helper'

describe Repository::StatusImage do
  include Support::ActiveRecord

  let!(:request) { Factory(:request, event_type: 'push', repository: repo) }
  let!(:build)   { Factory(:build, repository: repo, request: request, state: :passed) }
  let(:repo)     { Factory(:repository) }

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

    it 'returns :errored if the status of the last finished build is errored' do
      build.update_attributes(state: :errored)
      image = described_class.new(repo, nil)
      image.result.should == :errored
    end

    it 'returns :unknown if the status of the last finished build is unknown' do
      build.update_attributes(state: :created)
      image = described_class.new(repo, nil)
      image.result.should == :unknown
    end
  end

  describe 'given a branch' do
    it 'returns :passed if the last build on that branch has passed' do
      build.update_attributes(state: :passed)
      build.commit.update_attributes(branch: 'master')
      image = described_class.new(repo, 'master')
      image.result.should == :passing
    end

    it 'returns :failed if the last build on that branch has failed' do
      build.update_attributes(state: :failed)
      build.commit.update_attributes(branch: 'develop')
      image = described_class.new(repo, 'develop')
      image.result.should == :failing
    end

    it 'returns :failed if the last build on that branch has failed' do
      build.update_attributes(state: :errored)
      build.commit.update_attributes(branch: 'develop')
      image = described_class.new(repo, 'develop')
      image.result.should == :errored
    end
  end
end
