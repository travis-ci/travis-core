require 'spec_helper'
require 'travis/api'

describe Travis::Api::Http do
  describe 'builder' do
    let(:builder) { Travis::Api::Http.builder(:repository, :version => 'v1') }

    it 'returns the json builder class for the given type and version' do
      builder.should == Travis::Api::Http::V1::Repository
    end
  end

  describe 'data' do
    let(:repo)    { stub('repository') }
    let(:builder) { stub('builder', :data => nil) }
    let(:data)    { Travis::Api::Http::data(:repository, repo, { :foo => 'bar' }, { :version => 'v1' }) }

    before :each do
      Travis::Api::Http::V1::Repository.stubs(:new).returns(builder)
    end

    it 'instantiates a builder and returns the data' do
      Travis::Api::Http::V1::Repository.expects(:new).with(repo, :foo => 'bar').returns(builder)
      data
    end

    it 'returns the data from the builder instance' do
      builder.expects(:data).returns(:data => 'data')
      data.should == { :data => 'data' }
    end
  end
end

