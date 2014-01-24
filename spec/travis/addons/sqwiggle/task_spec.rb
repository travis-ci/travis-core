require 'spec_helper'
require 'rack'

describe Travis::Addons::Sqwiggle::Task do
  include Travis::Testing::Stubs

  let(:subject) { Travis::Addons::Sqwiggle::Task }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  before do
    subject.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    subject.new(payload, targets: targets).run
  end

  it "sends sqwiggle messages to the given targets" do
    targets = ['12345@room_1', '23456@room_2']
    message = %Q[svenfuchs/minimal - build number: 2 (master - 62aae5f : Sven Fuchs) -
          <a href="http://github.com/somerepo/somecomparison" target="_blank">build</a> has 
          <strong>passed</strong>
    ].squish

    expect_sqwiggle('12345', message)
    expect_sqwiggle('23456', message)

    run(targets)
    http.verify_stubbed_calls
  end

  # it 'using a custom template' do
  #   targets  = ['12345@room_1']
  #   template = ['%{repository}', '%{commit}']
  #   messages = ['svenfuchs/minimal', '62aae5f']

  #   payload['build']['config']['notifications'] = { hipchat: { template: template } }
  #   expect_hipchat('room_1', '12345', messages)

  #   run(targets)
  #   http.verify_stubbed_calls
  # end

  # it "sends HTML notifications if requested" do
  #   targets = ['12345@room_1']
  #   template = ['<a href="%{build_url}">Details</a>']
  #   messages = ['<a href="http://travis-ci.org/svenfuchs/minimal/builds/1">Details</a>']

  #   payload['build']['config']['notifications'] = { hipchat: { template: template, format: 'html' } }
  #   expect_hipchat('room_1', '12345', messages, 'message_format' => 'html')

  #   run(targets)
  #   http.verify_stubbed_calls
  # end

  # it 'works with a list as HipChat configuration' do
  #   targets  = ['12345@room_1']
  #   template = ['%{repository}', '%{commit}']
  #   messages = [
  #     'svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
  #     'Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
  #     'Build details: http://travis-ci.org/svenfuchs/minimal/builds/1'
  #   ]

  #   payload['build']['config']['notifications'] = { hipchat: [] }
  #   expect_hipchat('room_1', '12345', messages)

  #   run(targets)
  #   http.verify_stubbed_calls
  # end

  # it "sends gray messages for errored builds" do
  #   targets = ["12345@room_1"]
  #   messages = [
  #     "svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has errored",
  #     "Change view: https://github.com/svenfuchs/minimal/compare/master...develop",
  #     "Build details: http://travis-ci.org/svenfuchs/minimal/builds/1"
  #   ]

  #   payload["build"]["state"] = "errored"
  #   expect_hipchat("room_1", "12345", messages, "color" => "gray")

  #   run(targets)
  #   http.verify_stubbed_calls
  # end

  def expect_sqwiggle(token, payload)
    body = { 'room_id' => room_id, 'message' => message, 'color' => 'green', 'format' => 'text' }
    http.post("messages?auth_token=#{token}") do |env|
      env[:url].host.should == 'api.sqwiggle.com'
      env[:body].should == MultiJson.encode(payload)
    end
  end
end


