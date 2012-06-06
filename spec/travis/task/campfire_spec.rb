require 'spec_helper'

describe Travis::Task::Campfire do
  include Travis::Testing::Stubs

  let(:io)      { StringIO.new }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:data)    { Travis::Api.data(build, :for => 'event', :version => 'v2') }

  before do
    Travis.logger = Logger.new(io)
    Travis::Task::Campfire.any_instance.stubs(:http).returns(client)
  end

  def run(targets, data)
    Travis::Task::Campfire.new(targets, data).run
  end

  it 'sends campfire notifications to the room' do
    targets = ['account:token@room']

    expect_campfire('account', 'room', 'token', [
      '[travis-ci] svenfuchs/minimal#2 (master - 62aae5f : Sven Fuchs): the build has passed',
      '[travis-ci] Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
      "[travis-ci] Build details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}"
    ])
    run(targets, data)
    http.verify_stubbed_calls
  end

  def expect_campfire(account, room, token, body)
    host = "#{account}.campfirenow.com"
    path = "room/#{room}/speak.json"
    auth = Base64.encode64("#{token}:X").gsub("\n", '')

    body.each do |line|
      http.post(path) do |env|
        env[:request_headers]['authorization'].should == "Basic #{auth}"
        env[:url].host.should == host
        env[:body].should == MultiJson.encode({ :message => { :body => line } })
      end
    end
  end
end

