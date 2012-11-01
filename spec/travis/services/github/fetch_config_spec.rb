require 'spec_helper'

describe Travis::Services::Github::FetchConfig do
  include Travis::Testing::Stubs

  let(:subject)   { Travis::Services::Github::FetchConfig }
  let(:body)      { { 'content' => ['foo: Foo'].pack('m') } }
  let(:service)   { subject.new(nil, request: request) }
  let(:result)    { service.run }
  let(:exception) { GH::Error.new }

  before :each do
    GH.stubs(:[]).with(request.config_url).returns(body)
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

    it "returns { '.result' => 'not_found' } if a 404 is returned" do
      exception.stubs(info: { response_status: 404 })
      GH.stubs(:[]).raises(exception)
      result['.result'].should == 'not_found'
    end

    it "returns { '.result' => 'server_error' } if a 500 is returned" do
      exception.stubs(info: { response_status: 500 })
      GH.stubs(:[]).raises(exception)
      result['.result'].should == 'server_error'
    end

    it "returns { '.result' => 'parsing_error' } if the .travis.yml is invalid" do
      GH.stubs(:[]).returns("\tfoo: Foo")
      result['.result'].should == 'parsing_failed'
    end
  end
end
