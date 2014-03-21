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
    targets = ['12345@2', '23456@3']

    message = %Q[svenfuchs/minimal - build number: 2 (master - 62aae5f : Sven Fuchs) -
          <a href="http://travis-ci.org/svenfuchs/minimal/builds/1" target="_blank">build</a> has
          <strong>passed</strong>
    ].squish

    sqwiggle_payload = {
      text: message,
      format: 'html',
      color: 'green',
      parse: false
    }

    expect_sqwiggle('12345', sqwiggle_payload, 2)
    expect_sqwiggle('23456', sqwiggle_payload, 3)

    run(targets)
    http.verify_stubbed_calls
  end

  it 'using a custom template' do
    targets  = ['12345@1']
    template = '%{repository} %{commit}'
    message = 'svenfuchs/minimal 62aae5f'

    payload['build']['config']['notifications'] = { sqwiggle: { template: template } }

    sqwiggle_payload = {
      text: message,
      format: 'html',
      color: 'green',
      parse: false
    }

    expect_sqwiggle('12345', sqwiggle_payload, 1)

    run(targets)
    http.verify_stubbed_calls
  end

  it 'uses template_success for successful build if defined' do
    targets  = ['12345@1']
    template = '%{repository} %{commit}'
    message = 'svenfuchs/minimal 62aae5f'

    payload['build']['config']['notifications'] = { sqwiggle: { template_success: template } }

    sqwiggle_payload = {
      text: message,
      format: 'html',
      color: 'green',
      parse: false
    }

    expect_sqwiggle('12345', sqwiggle_payload, 1)

    run(targets)
    http.verify_stubbed_calls
  end

  it 'uses template_failure for failed build if defined' do
    targets  = ['12345@1']
    template = '%{repository} %{commit}'
    message = 'svenfuchs/minimal 62aae5f'

    payload['build']['config']['notifications'] = { sqwiggle: { template_failure: template } }
    payload['build']['state'] = 'failed'

    sqwiggle_payload = {
      text: message,
      format: 'html',
      color: 'red',
      parse: false
    }

    expect_sqwiggle('12345', sqwiggle_payload, 1)

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends red messages for failed builds" do
    targets = ["12345@1"]

    message = %Q[svenfuchs/minimal - build number: 2 (master - 62aae5f : Sven Fuchs) -
          <a href="http://travis-ci.org/svenfuchs/minimal/builds/1" target="_blank">build</a> has
          <strong>failed</strong>
    ].squish

    sqwiggle_payload = {
      text: message,
      format: 'html',
      color: 'red',
      parse: false
    }
    payload["build"]["state"] = "failed"

    expect_sqwiggle("12345", sqwiggle_payload, 1, color:"red")

    run(targets)
    http.verify_stubbed_calls
  end

  it "sends gray messages for errored builds" do
    targets = ["12345@1"]

    message = %Q[svenfuchs/minimal - build number: 2 (master - 62aae5f : Sven Fuchs) -
          <a href="http://travis-ci.org/svenfuchs/minimal/builds/1" target="_blank">build</a> has
          <strong>errored</strong>
    ].squish

    sqwiggle_payload = {
      text: message,
      format: 'html',
      color: 'gray',
      parse: false
    }

    payload["build"]["state"] = "errored"
    expect_sqwiggle("12345", sqwiggle_payload, 1, color:"grey")

    run(targets)
    http.verify_stubbed_calls
  end

  def expect_sqwiggle(token, payload, room_id, extras={})
    fp = payload.merge({room_id:room_id})
    fp.merge extras
    http.post("messages?auth_token=#{token}") do |env|
      env[:url].host.should == 'api.sqwiggle.com'
      env[:body].should == MultiJson.encode(fp)
    end
  end
end


