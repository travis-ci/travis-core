require 'spec_helper'

describe Commit do
  include Support::ActiveRecord

  let(:commit) { Commit.new(:commit => '12345678') }

  describe 'pull_request_number' do
    context 'when commit is from pull request' do
      before { commit.ref = 'refs/pull/180/merge' }

      it 'returns pull request\'s number' do
        commit.pull_request_number.should == 180
      end
    end

    context 'when commit is not from pull request' do
      before { commit.ref = 'refs/branch/master' }

      it 'returns nil' do
        commit.pull_request_number.should be_nil
      end
    end
  end

  describe 'pull_request?' do
    it 'is false for a nil ref' do
      commit.ref = nil
      commit.pull_request?.should be_false
    end

    it 'is false for a ref named ref/branch/master' do
      commit.ref = 'refs/branch/master'
      commit.pull_request?.should be_false
    end

    it 'is false for a ref named ref/pull/180/head' do
      commit.ref = 'refs/pull/180/head'
      commit.pull_request?.should be_false
    end

    it 'is true for a ref named ref/pull/180/merge' do
      commit.ref = 'refs/pull/180/merge'
      commit.pull_request?.should be_true
    end
  end
end
