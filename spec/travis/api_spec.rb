require 'spec_helper'

describe Travis::Api do
  describe 'data' do
    let(:repo)    { stub('repository') }
    let(:repos)   { stub('repositories', :klass => Repository) }
    let(:builder) { stub('builder', :data => 'data') }

    def data_for(object)
      Travis::Api.data(object, { :version => 'v1', :params => { :some => 'thing' } })
    end

    before :each do
      repo.class.stubs(:base_class).returns(stub('base_class', :name => 'Repository'))
      Travis::Api::V1::Http::Repository.stubs(:new).returns(builder)
    end

    describe 'instantiates a builder and returns the data' do
      it 'given an object that responds to :base_class (aka ActiveRecord::Base)' do
        Travis::Api::V1::Http::Repository.expects(:new).with(repo, :some => 'thing').returns(builder)
        data_for(repo).should == 'data'
      end

      it 'given an object that responds to :klass (aka Arel::Relation)' do
        Travis::Api::V1::Http::Repositories.expects(:new).with(repos, :some => 'thing').returns(builder)
        data_for(repos).should == 'data'
      end
    end

    it 'returns the data from the builder instance' do
      builder.expects(:data).returns('data')
      data_for(repo).should == 'data'
    end

    describe '#builder' do
      before do
        Travis::Api.const_set :V5, Class.new
        Travis::Api::V5.const_set :Http, Class.new
        Travis::Api::V5::Http.const_set :Job, Class.new
        Travis::Api::V5::Http::Job.const_set :Test, Class.new
        Travis::Api.const_set :Foo, Class.new
      end

      after do
        Travis::Api.send :remove_const, :V5
        Travis::Api.send :remove_const, :Foo
      end

      it 'finds given constant' do
        const = Travis::Api.builder('', for: :http, type: 'job/test', version: :v5)
        const.should == Travis::Api::V5::Http::Job::Test
      end

      it 'returns nil if only part of the constant is matched' do
        const = Travis::Api.builder('', for: :foo, type: 'job/test', version: :v5)
        const.should be_nil
      end

      it 'does not raise an error if constant name is wrong' do
        expect {
          const = Travis::Api.builder('', for: :pusher, type: 'job/test', version: '5')
          const.should be_nil
        }.to_not raise_error
      end
    end
  end
end
