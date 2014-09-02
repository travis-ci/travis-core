require 'spec_helper'

describe Travis::Github::Education do
  let(:education) { described_class.new('an-oauth-token') }

  before { WebMock.disable_net_connect! }
  after  { WebMock.allow_net_connect! }

  it 'fetches student data' do
    stub_request(:get, 'https://education.github.com/api/user').
      with(headers: { 'Authorization' => 'token an-oauth-token' }).
      to_return(body: '{ "student": true }')

    education.data.should == { "student" => true }
  end

  it 'returns empty hash on json parse error' do
    stub_request(:get, 'https://education.github.com/api/user').
      with(headers: { 'Authorization' => 'token an-oauth-token' }).
      to_return(body: 'not json')

    education.data.should == {}
  end

  it 'returns empty hash on error response' do
    stub_request(:get, 'https://education.github.com/api/user').
      with(headers: { 'Authorization' => 'token an-oauth-token' }).
      to_return(body: '{}', status: 404)

    education.data.should == {}
  end

  describe 'student?' do
    it 'is true when student field is true in the response' do
      education.expects(:data).returns({ 'student' => true })
      education.student?.should be_true
    end
  end
end
