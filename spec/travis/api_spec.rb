require 'spec_helper'
require 'travis/api'

describe Travis::Api do
  describe 'data' do
    let(:repo)    { stub('repository') }
    let(:builder) { stub('builder', :data => nil) }
    let(:data)    { Travis::Api.data(repo, { :version => 'v1', :params => { :foo => 'bar' } }) }

    before :each do
      repo.class.stubs(:base_class).returns(stub('base_class', :name => 'Repository'))
      Travis::Api::V1::Http::Repository.stubs(:new).returns(builder)
    end

    it 'instantiates a builder and returns the data' do
      Travis::Api::V1::Http::Repository.expects(:new).with(repo, :foo => 'bar').returns(builder)
      data
    end

    it 'returns the data from the builder instance' do
      builder.expects(:data).returns(:data => 'data')
      data.should == { :data => 'data' }
    end
  end
end
