require 'spec_helper'

describe Travis::Services::Github::FetchConfig do
  include Travis::Testing::Stubs

  let(:subject)  { Travis::Services::Github::FetchConfig }
  let(:url)      { 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml' }
  let(:response) { stub('response', :success? => true, :body => 'foo: Foo') }
  let(:http)     { stub('http', :get => response) }
  let(:service)  { subject.new(url) }
  let(:result)   { service.run }

  before :each do
    service.stubs(:http).returns(http)
  end

  describe 'config' do
    it 'returns a hash' do
      result.should be_a(Hash)
    end

    it 'yaml parses the response body if the response is successful' do
      result['foo'].should == 'Foo'
    end

    it "merges { '.result' => 'configured' } to the actual configuration" do
      result['.result'].should == 'configured'
    end

    it "returns { '.result' => 'not_found' } if the repository has not .travis.yml" do
      response.expects(:success?).returns(false)
      response.expects(:status).returns(404)
      result['.result'].should == 'not_found'
    end

    it "returns { '.result' => 'server_error' } if a 500 server error is returned" do
      response.expects(:success?).returns(false)
      response.expects(:status).returns(500)
      result['.result'].should == 'server_error'
    end

    describe 'invalid yml' do
      let(:response) { stub('response', :success? => true, :body => "\tfoo: Foo") }

      it "returns { '.result' => 'parsing_error' } if the .travis.yml is invalid" do
        result['.result'].should == 'parsing_failed'
      end
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
      service.send(:http_options)[:ssl][:ca_path].should == '/path/to/certs'
    end

    it 'returns a hash containing a :ca_file value if present' do
      Travis.config.ssl = { :ca_file => '/path/to/cert.file' }
      service.send(:http_options)[:ssl][:ca_file].should == '/path/to/cert.file'
    end
  end
end


