require 'spec_helper'

describe Travis::Services::FindAdmin::Cache do
  include Travis::Testing::Stubs

  let(:redis)   { Travis.redis }
  let(:block)   { -> { yielded << true; user } }
  let(:yielded) { [] }

  let(:params)  { { cache: true } }
  let(:result)  { described_class.new(repo, params).lookup(&block) }

  before :each do
    Travis::Features.stubs(:enabled_for_all?).with(:allow_cache_admin).returns(true)
  end

  describe 'with :allow_cache_admin not enabled' do
    before :each do
      Travis::Features.stubs(:enabled_for_all?).with(:allow_cache_admin).returns(false)
    end

    it 'does not try to find the admin from the cache' do
      cache.expects(:find_admin).never
      result
    end

    it 'does not store the admin to the cache' do
      cache.expects(:store_admin).never
      result
    end
  end

  describe 'with params[:cache] not given' do
    let(:params) { {} }

    it 'does not try to find the admin from the cache' do
      cache.expects(:find_admin).never
      result
    end

    it 'does not store the admin to the cache' do
      cache.expects(:store_admin).never
      result
    end
  end

  describe 'with params[:cache] given and :allow_cache_admin enabled' do
    before :each do
      User.stubs(:find).returns(user)
      redis.stubs(:set).with("repository:admin:#{repo.id}", 1)
    end

    it 'looks the admin up from Redis' do
      redis.expects(:get).with("repository:admin:#{repo.id}")
      result
    end

    describe 'hitting the cache' do
      before :each do
        redis.stubs(:get).with("repository:admin:#{repo.id}").returns(1)
      end

      it 'finds the user' do
        result.should == user
      end

      it 'does not yield the block' do
        result
        yielded.should be_empty
      end
    end

    describe 'not hitting the cache' do
      before :each do
        redis.stubs(:get).with("repository:admin:#{repo.id}").returns(nil)
      end

      it 'yields the block' do
        result
        yielded.should_not be_empty
      end

      it 'stores the user' do
        redis.expects(:set).with("repository:admin:#{repo.id}", 1)
        result
      end

      it 'returns the user' do
        result.should == user
      end
    end
  end
end
