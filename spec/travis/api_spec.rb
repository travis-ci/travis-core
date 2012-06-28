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
  end
end
