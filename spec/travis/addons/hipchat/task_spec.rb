require 'spec_helper'
require 'rack'
require 'securerandom'
require 'open-uri'

describe Travis::Addons::Hipchat::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Hipchat::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }
  let(:room_1_token) { SecureRandom.hex 15}
  let(:room_2_token) { SecureRandom.hex 15}
  let(:room_3_token_v2) { SecureRandom.hex 20}

  before do
    subject.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    subject.new(payload, targets: targets).run
  end

  it "sends hipchat notifications to the given targets" do
    targets = ["#{room_1_token}@room_1", "#{room_2_token}@room_2", "#{room_3_token_v2}@[foo]"]
    message = [
      'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
      'Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
      'Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
    ]

    expect_hipchat('room_1', room_1_token, message)
    expect_hipchat('room_2', room_2_token, message)
    expect_hipchat_v2('[foo]', room_3_token_v2, message)

    run(targets)
    http.verify_stubbed_calls
  end

  it 'using a custom template' do
    targets  = ["#{room_1_token}@room_1"]
    template = ['%{repository}', '%{commit}']
    messages = ['svenfuchs/minimal', '62aae5f']

    payload['build']['config']['notifications'] = { hipchat: { template: template } }
    expect_hipchat('room_1', room_1_token, messages)

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends HTML notifications if requested" do
    targets = ["#{room_1_token}@room_1"]
    template = ['<a href="%{build_url}">Details</a>']
    messages = ['<a href="http://travis-ci.org/svenfuchs/minimal/builds/1">Details</a>']

    payload['build']['config']['notifications'] = { hipchat: { template: template, format: 'html' } }
    expect_hipchat('room_1', room_1_token, messages, 'message_format' => 'html')

    run(targets)
    http.verify_stubbed_calls
  end

  it 'works with a list as HipChat configuration' do
    targets  = ["#{room_1_token}@room_1"]
    template = ['%{repository}', '%{commit}']
    messages = [
      'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
      'Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
      'Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
    ]

    payload['build']['config']['notifications'] = { hipchat: [] }
    expect_hipchat('room_1', room_1_token, messages)

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends gray messages for errored builds" do
    targets = ["#{room_1_token}@room_1"]
    messages = [
      "svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has errored",
      "Change view: https://github.com/svenfuchs/minimal/compare/master...develop",
      "Build details: http://travis-ci.org/svenfuchs/minimal/builds/1"
    ]

    payload["build"]["state"] = "errored"
    expect_hipchat("room_1", room_1_token, messages, "color" => "gray")

    run(targets)
    http.verify_stubbed_calls
  end

  describe "handling errors" do
    it "ignores an empty targets list" do
      expect {
        run(["#{SecureRandom.hex 50}@room_1"])
      }.to_not raise_error
    end
  end

  def expect_hipchat(room_id, token, lines, extra_body={})
    Array(lines).each do |line|
      body = { 'room_id' => room_id, 'from' => 'Travis CI', 'message' => line, 'color' => 'green', 'message_format' => 'text' }.merge(extra_body)
      http.post("v1/rooms/message?format=json&auth_token=#{token}") do |env|
        env[:url].host.should == 'api.hipchat.com'
        Rack::Utils.parse_query(env[:body]).should == body
      end
    end
  end

  def expect_hipchat_v2(room_id, token, lines, extra_body={})
    Array(lines).each do |line|
      body = { 'message' => line, 'color' => 'green', 'message_format' => 'text' }.merge(extra_body).to_json
      http.post("https://api.hipchat.com/v2/room/#{URI::encode(room_id, Travis::Addons::Hipchat::HttpHelper::UNSAFE_URL_CHARS)}/notification?auth_token=#{token}") do |env|
        env[:request_headers]['Content-Type'].should == 'application/json'
        env[:body].should == body
      end
    end
  end

end

