require 'spec_helper'

describe Travis::Logs::Services::Archive do
  let(:params)  { { type: 'log', id: 1 } }
  let(:service) { described_class.new(params) }
  let(:body)    { stub(body: 'the log') }
  let(:http)    { stub('http', get: body, put: body) }
  let(:s3)      { stub('s3', store: nil) }

  before :each do
    service.stubs(:http).returns(http)
    service.stubs(:s3).returns(s3)
  end

  describe 'in production' do
    before :each do
      Travis.stubs(:env).returns('production')
    end

    it 'fetches the log from the api' do
      http.expects(:get).with('https://api.travis-ci.org/artifacts/1.txt').returns(body)
      service.run
    end

    it 'stores the log to s3' do
      s3.expects(:store).with('archive.travis-ci.org', 'v2/jobs/1/log.txt', 'the log')
      service.run
    end

    it 'reports to the api' do
      data = MultiJson.encode(archived_at: Time.now)
      http.expects(:put).with('https://api.travis-ci.org/artifacts/1', data).returns(body)
      service.run
    end
  end

  describe 'in staging' do
    before :each do
      Travis.stubs(:env).returns('staging')
    end

    it 'fetches the log from the api' do
      http.expects(:get).with('https://api-staging.travis-ci.org/artifacts/1.txt').returns(body)
      service.run
    end

    it 'stores the log to s3' do
      s3.expects(:store).with('archive-staging.travis-ci.org', 'v2/jobs/1/log.txt', 'the log')
      service.run
    end

    it 'reports to the api' do
      data = MultiJson.encode(archived_at: Time.now)
      http.expects(:put).with('https://api-staging.travis-ci.org/artifacts/1', data).returns(body)
      service.run
    end
  end
end
