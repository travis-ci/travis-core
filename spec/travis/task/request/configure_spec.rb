require 'spec_helper'

describe Travis::Task::Request::Configure do
  let(:response) { stub('response', :success? => true, :body => 'foo: Foo') }
  let(:http)     { stub('http', :get => response) }
  let(:payload)  { Hashr.new(QUEUE_PAYLOADS['job:configure']) }
  let(:commit)   { payload[:build] }
  let(:subject)  { Travis::Task::Request::Configure.new(commit, http) }
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
      response.expects(:status).returns(404)
      result['config']['.result'].should == 'not_found'
    end

    it "returns { '.result' => 'server_error' } if a 500 server error is returned" do
      response.expects(:success?).returns(false)
      response.expects(:status).returns(500)
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

  describe 'http_options' do
    before :each do
      @ssl = Travis.config.ssl
    end

    after :each do
      Travis.config.ssl = @ssl
    end

    it 'returns a hash containing a :ca_path value if present' do
      Travis.config.ssl = { :ca_path => '/path/to/certs' }
      subject.send(:http_options)[:ssl][:ca_path].should == '/path/to/certs'
    end

    it 'returns a hash containing a :ca_file value if present' do
      Travis.config.ssl = { :ca_file => '/path/to/cert.file' }
      subject.send(:http_options)[:ssl][:ca_file].should == '/path/to/cert.file'
    end
  end
end
