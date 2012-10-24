require 'spec_helper'

describe Travis::Task::Flowdock do
  include Travis::Testing::Stubs

  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:payload) { Travis::Api.data(build, for: 'event', version: 'v0') }

  before do
    Travis::Task::Flowdock.any_instance.stubs(:http).returns(client)
  end

  def run(targets)
    Travis::Task::Flowdock.new(payload, targets: targets).run
    http.verify_stubbed_calls
  end

  it "sends flowdock notifications to the Team Inbox with the given tokens" do
    targets = ['12345', '23456']
    message = <<-msg.gsub(/^\s*/m, '')
      <ul>
      <li><code><a href="https://github.com/svenfuchs/minimal">svenfuchs/minimal</a></code> build #2 has passed!</li>
      <li>Branch: <code>master</code></li>
      <li>Latest commit: <code><a href="https://github.com/svenfuchs/minimal/commit/62aae5f70ceee39123ef">62aae5f</a></code> by <a href="mailto:svenfuchs@artweb-design.de">Sven Fuchs</a></li>
      <li>Change view: https://github.com/svenfuchs/minimal/compare/master...develop</li>
      <li>Build details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}</li>
      </ul>
    msg
    payload = {
      source:       'Travis',
      from_address: 'build+ok@flowdock.com',
      subject:      'svenfuchs/minimal build #2 has passed!',
      content:      message,
      from_name:    'CI',
      project:      'Build Status',
      format:       'html',
      tags:         ['ci', 'ok'],
      link:         "http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}"
    }

    expect_flowdock('12345', payload)
    expect_flowdock('23456', payload)

    run(targets)
  end

  def expect_flowdock(token, payload)
    http.post("v1/messages/team_inbox/#{token}") do |env|
      env[:url].host.should == 'api.flowdock.com'
      env[:body].should == payload
    end
  end
end

