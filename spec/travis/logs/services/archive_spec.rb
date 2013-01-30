require 'spec_helper'

describe Travis::Logs::Services::Archive do
  include Support::Silence

  let(:log)      { 'the log' }
  let(:params)   { { type: 'log', id: 1, job_id: 2, no_sleep: true } }
  let(:response) { stub('response', status: 200, body: log, headers: { 'content-length' => log.length }) }
  let(:http)     { stub('http', head: response, get: response, put: response) }
  let(:s3)       { stub('s3', store: nil) }
  let(:service)  { described_class.new(params) }

  before :each do
    service.stubs(:http).returns(http)
    service.stubs(:s3).returns(s3)
    Travis::Instrumentation.stubs(:meter)
  end

  shared_examples_for 'archive' do |env|
    it 'fetches the log from the api' do
      url = "https://api#{"-#{env}" if env}.travis-ci.org/artifacts/1.txt"
      http.expects(:get).with(url).returns(response)
      service.run
    end

    it 'retries and finally raises if fetch fails' do
      http.expects(:get).raises(described_class::FetchFailed.new('url', 503, 'message')).times(5)
      Travis::Instrumentation.expects(:meter).with('travis.logs.services.archive.retries.fetch').times(4)
      -> { silence { service.run } }.should raise_error(described_class::FetchFailed)
    end

    it 'retries and finally raises if fetch can not find the log' do
      response.stubs(status: 404, body: 'not found')
      Travis::Instrumentation.expects(:meter).with('travis.logs.services.archive.retries.fetch').times(4)
      -> { silence { service.run } }.should raise_error(described_class::FetchFailed)
    end

    it 'stores the log to s3' do
      s3.expects(:store).with(log)
      service.run
    end

    it 'retries and finally raises if storage fails' do
      s3.expects(:store).raises(AWS::Errors::ServerError.new).times(5)
      Travis::Instrumentation.expects(:meter).with('travis.logs.services.archive.retries.store').times(4)
      -> { silence { service.run } }.should raise_error(AWS::Errors::ServerError)
    end

    it 'verifies the log size' do
      url = "http://archive#{"-#{env}" if env}.travis-ci.org/jobs/2/log.txt"
      http.expects(:head).with(url).returns(response)
      service.run
    end

    it 'retries and finally raises if verification fails' do
      response.headers['content-length'] += 1
      http.expects(:head).returns(response).times(5)
      Travis::Instrumentation.expects(:meter).with('travis.logs.services.archive.retries.verify').times(4)
      -> { silence { service.run } }.should raise_error(described_class::VerificationFailed)
    end

    it 'reports to the api' do
      url = "https://api#{"-#{env}" if env}.travis-ci.org/artifacts/1"
      http.expects(:put).with(url, { archived_at: Time.now, archive_verified: true }, token: 'token').returns(response)
      service.run
    end

    it 'retries and finally raises if reporting fails' do
      http.expects(:put).raises(Faraday::Error::ClientError.new(nil)).times(5)
      Travis::Instrumentation.expects(:meter).with('travis.logs.services.archive.retries.report').times(4)
      -> { silence { service.run } }.should raise_error(Faraday::Error::ClientError)
    end
  end

  describe 'in production' do
    before :each do
      Travis.stubs(:env).returns('production')
    end

    it_behaves_like 'archive'
  end

  describe 'in staging' do
    before :each do
      Travis.stubs(:env).returns('staging')
    end

    it_behaves_like 'archive', 'staging'
  end
end
