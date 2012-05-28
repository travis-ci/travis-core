require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Handler::Campfire do
  include Support::ActiveRecord

  let(:handler) { Travis::Notifications::Handler::Campfire.new }
  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:build)   { Factory(:build, :config => { 'notifications' => { 'campfire' => 'account:token@room' } }) }
  let(:io)      { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:campfire]
    handler.stubs(:client).returns(client)
  end

  subject { lambda { handler.notify('build:finished', build) } }

  it 'build:started does not notify campfire' do
    Travis::Notifications::Handler::Campfire.any_instance.expects(:notify).never
    Travis::Notifications.dispatch('build:started', build)
  end

  it 'build:finish notifies campfire' do
    Travis::Notifications::Handler::Campfire.any_instance.expects(:notify)
    Travis::Notifications.dispatch('build:finished', build)
  end

  it 'sends campfire notifications to the room' do
    build.config[:notifications][:campfire] = 'account:token@room'

    expect_campfire('account', 'room', 'token', [
      '[travis-ci] svenfuchs/minimal#1 (master - 62aae5f : Sven Fuchs): the build has passed',
      '[travis-ci] Change view: https://github.com/svenfuchs/minimal/compare/master...develop',
      "[travis-ci] Build details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}"
    ])
    subject.call
    http.verify_stubbed_calls
  end

  it 'sends campfire notifications to the rooms given as an array' do
    build.config[:notifications][:campfire] = ['account:token@room', 'another-account:another-token@another-room']
    client.expects(:post).times(6)
    subject.call
  end

  it 'sends no campfire notification if the given url is blank' do
    build.config[:notifications][:campfire] = ''
    client.expects(:post).never
    subject.call
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
