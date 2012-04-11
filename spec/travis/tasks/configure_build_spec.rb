require 'spec_helper'
require 'support/payloads'
require 'travis/tasks/configure_build'

describe Travis::Tasks::ConfigureBuild do
  let(:response) { stub('response', :success? => true, :body => 'foo: Foo') }
  let(:http)     { stub('http', :get => response) }
  let(:payload)  { Hashr.new(QUEUE_PAYLOADS['job:configure']) }
  let(:commit)   { payload[:build] }
  let(:subject)  { Travis::Tasks::ConfigureBuild.new(commit, http) }
  let(:result)   { subject.run }

  describe 'run' do
    it 'returns a hash' do
      result.should be_a(Hash)
    end

    it 'yaml parses the response body if the response is successful' do
      result['config']['foo'].should == 'Foo'
    end

    it "merges { '.result' => 'configured' } to the actual configuration" do
      result['config']['.result'].should == 'configured'
    end

    it "returns { '.result' => 'not_found' } if the repository has not .travis.yml" do
      response.expects(:success?).returns(false)
      response.expects(:code).returns(404)
      result['config']['.result'].should == 'not_found'
    end

    it "returns { '.result' => 'server_error' } if a 500 server error is returned" do
      response.expects(:success?).returns(false)
      response.expects(:code).returns(500)
      result['config']['.result'].should == 'server_error'
    end

    it "returns { '.result' => 'parsing_error' } if the .travis.yml is invalid" do
      YAML.stubs(:load).raises(StandardError)
      result['config']['.result'].should == 'parsing_failed'
    end

    it "uses the commits's config_url" do
      commit.expects(:config_url)
      result
    end
  end
end
