require 'spec_helper'

describe Travis::UrlShortener::Bitly do
  subject { Travis::UrlShortener::Bitly }

  describe ".create" do
    it "should return a new Bitly shortener" do
      subject.create.should be_a Travis::UrlShortener::Bitly
    end
  end

  describe "#connection" do
    it "returns a connection with ca_path set if ca_path is configured" do
      bitly = subject.new({}, { :ssl => { :ca_path => '/one/two/three' } })
      bitly.connection.ssl[:ca_path].should == '/one/two/three'
    end

    it "returns a connection with ca_file set if ca_file is configured" do
      bitly = subject.new({}, { :ssl => { :ca_file => '/one/two/three.crt' } })
      bitly.connection.ssl[:ca_file].should == '/one/two/three.crt'
    end

    it "returns a connection with apiKey and login params set if set via the config" do
      bitly = subject.new(:api_key => '1234', :login => '5678')
      bitly.connection.params.should == { 'apiKey' => '1234', 'login' => '5678' }
    end

    it "returns a connection with no params set if not set via the initializer config" do
      bitly = subject.new
      bitly.connection.params.should == {}
    end
  end

  describe "#shorten" do
    before(:each) do
      bitly.connection.builder.delete(Faraday::Adapter::NetHttp)
      bitly.connection.adapter(:test, stubs)
    end

    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/v3/shorten?longUrl=http%3A%2F%2Fwww.travis-ci.org') { [200, {}, "{\"data\":{\"url\":\"http://trvs.io/1234\"}}"] }
        stub.get('/v3/shorten?longUrl=http%3A%2F%2Ftwitter.com%2Ftravisci') { raise Net::HTTPError }
      end
    end
    let(:bitly) { Travis::UrlShortener::Bitly.new }

    it "shortens a url" do
      bitly.shorten('http://www.travis-ci.org').should == 'http://trvs.io/1234'
    end

    it "returns the original long url if an error occurs" do
      bitly.shorten('http://twitter.com/travisci').should == 'http://twitter.com/travisci'
    end

    it "returns the response when :return_response is true" do
      bitly.shorten('http://www.travis-ci.org', :return_response => true).should be_a Hash
    end
  end
end