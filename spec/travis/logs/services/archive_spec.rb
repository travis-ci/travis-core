require 'spec_helper'

describe Travis::Logs::Services::Archive do
  let(:log)      { 'the log' }
  let(:params)   { { type: 'log', id: 1, job_id: 2, no_retries: true } }
  let(:response) { stub('response', body: log, headers: { 'content-length' => log.length }) }
  let(:http)     { stub('http', head: response, get: response, put: response) }
  let(:s3)       { stub('s3', store: nil) }
  let(:service)  { described_class.new(params) }

  before :each do
    service.stubs(:http).returns(http)
    service.stubs(:s3).returns(s3)
  end

  shared_examples_for 'archive' do |env|
    it 'fetches the log from the api' do
      url = "https://api#{"-#{env}" if env}.travis-ci.org/artifacts/1.txt"
      http.expects(:get).with(url).returns(response)
      service.run
    end

    it 'stores the log to s3' do
      s3.expects(:store).with(log)
      service.run
    end

    it 'verifies the log size' do
      url = "http://archive#{"-#{env}" if env}.travis-ci.org/jobs/2/log.txt"
      http.expects(:head).with(url).returns(response)
      service.run
    end

    it 'raises if verification fails' do
      response.headers['content-length'] += 1
      http.expects(:head).returns(response)
      -> { service.run }.should raise_error(described_class::VerificationFailed)
    end

    it 'reports to the api' do
      url = "https://api#{"-#{env}" if env}.travis-ci.org/artifacts/1"
      http.expects(:put).with(url, { archived_at: Time.now, archive_verified: true }, token: 'token').returns(response)
      service.run
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
