require 'spec_helper'

describe Job::Limit::ByOwner do
  include Support::ActiveRecord

  describe 'all' do
    before :each do
      Job::Test.any_instance.stubs(:enqueueable?).returns(false) # prevent jobs to enqueue themselves on create
      Job::Queue.stubs(:for).returns(stub(:name => queue))
      6.times { Factory(:test, :owner => owner, :state => :created) }
    end

    let(:limit) { Job::Limit::ByOwner.new(owner) }

    describe 'given a public queue' do
      let(:owner) { Factory(:org, :login => 'travis-ci') }
      let(:queue) { 'builds.common' }

      it 'jobs are on the given queue' do
        limit.all.map(&:queue).uniq.should == ['builds.common']
      end

      it 'jobs are :created' do
        limit.all.map(&:state).uniq.should == ['created']
      end

      it 'jobs are limited' do
        limit.all.size.should == 5
      end
    end

    describe 'given a custom queue' do
      let(:owner) { Factory(:org, :login => 'rails') }
      let(:queue) { 'builds.rails' }

      it 'jobs are on the given queue' do
        limit.all.map(&:queue).uniq.should == ['builds.rails']
      end

      it 'jobs are :created' do
        limit.all.map(&:state).uniq.should == ['created']
      end

      it 'jobs are not limited' do
        limit.all.size.should == 6
      end
    end
  end

  describe 'custom_queue?' do
    def limit(owner)
      Job::Limit::ByOwner.new(owner)
    end

    it 'returns true for rails' do
      limit(Factory(:org, :login => 'rails')).custom_queue?.should be_true
    end

    it 'returns true for spree' do
      limit(Factory(:org, :login => 'spree')).custom_queue?.should be_true
    end

    it 'returns false for travis-ci' do
      limit(Factory(:org, :login => 'travis-ci')).custom_queue?.should be_false
    end
  end
end

