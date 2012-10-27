require 'spec_helper'

describe Travis::Addons::Campfire::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Campfire::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  before do
    subject.any_instance.stubs(:http).returns(client)
    Travis::Features.stubs(:active?).returns(true)
  end

  def run(targets)
    subject.new(payload, targets: targets).run
  end

  it "sends campfire notifications to the given targets" do
    targets = ['account-1:token-1@1234', 'account-2:token-2@2345']
    message = [
      '[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
      '[travis-ci] Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
      '[travis-ci] Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
    ]

    expect_campfire('account-1', '1234', 'token-1', message)
    expect_campfire('account-2', '2345', 'token-2', message)

    run(targets)
    http.verify_stubbed_calls
  end

  it 'using a custom template' do
    targets  = ['account-1:token-1@1234']
    template = ['%{repository}', '%{commit}']
    messages = ['svenfuchs/minimal', '62aae5f']

    payload['build']['config']['notifications'] = { campfire: { template: template } }
    expect_campfire('account-1', '1234', 'token-1', messages)

    run(targets)
    http.verify_stubbed_calls
  end

  def expect_campfire(account, room, token, body)
    host = "#{account}.campfirenow.com"
    path = "room/#{room}/speak.json"
    auth = Base64.encode64("#{token}:X").gsub("\n", '')

    Array(body).each do |line|
      http.post(path, { message: { body: line } }) do |env|
        env[:request_headers]['authorization'].should == "Basic #{auth}"
        env[:url].host.should == host
      end
    end
  end
end

