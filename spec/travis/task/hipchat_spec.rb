require 'spec_helper'
require 'rack'

describe Travis::Task::Hipchat do
  include Travis::Testing::Stubs

  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  before do
    Travis::Task::Hipchat.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    Travis::Task::Hipchat.new(payload, targets: targets).run
  end

  it "sends hipchat notifications to the given targets" do
    targets = ['12345@room_1', '23456@room_2']
    message = [
      'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
      'Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
      'Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
    ]

    expect_hipchat('room_1', '12345', message)
    expect_hipchat('room_2', '23456', message)

    run(targets)
    http.verify_stubbed_calls
  end

  it 'using a custom template' do
    targets  = ['12345@room_1']
    template = ['%{repository}', '%{commit}']
    messages = ['svenfuchs/minimal', '62aae5f']

    payload['build']['config']['notifications'] = { hipchat: { template: template } }
    expect_hipchat('room_1', '12345', messages)

    run(targets)
    http.verify_stubbed_calls
  end

  def expect_hipchat(room_id, token, lines)
    Array(lines).each do |line|
      body = { 'room_id' => room_id, 'from' => 'Travis CI', 'message' => line, 'color' => 'green', 'message_format' => 'text' }
      http.post("v1/rooms/message?format=json&auth_token=#{token}") do |env|
        env[:url].host.should == 'api.hipchat.com'
        Rack::Utils.parse_query(env[:body]).should == body
      end
    end
  end
end

