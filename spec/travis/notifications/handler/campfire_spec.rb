require 'spec_helper'

describe Travis::Notifications::Handler::Campfire do

  before do
    Travis.config.notifications = [:campfire]
    stub_http
  end

  let(:dispatch) { lambda { |event, object| Travis::Notifications.dispatch(event, object) } }

  it "sends campfire notifications to the rooms given as an array" do
    targets = ['evome:apitoken@42', 'rails:sometoken@69']
    build = Factory(:build, :config => { 'notifications' => { 'campfire' => targets } })
    dispatch.should post_campfire_on('build:finished', build, :to => targets)
  end

  it "sends campfire notifications to the room given as a string" do
    target = 'evome:apitoken@42'
    build = Factory(:build, :config => { 'notifications' => { 'campfire' => target } })
    dispatch.should post_campfire_on('build:finished', build, :to => [target])
  end

  it "sends no campfire notification if the given url is blank" do
    build = Factory(:build, :config => { 'notifications' => { 'campfire' => '' } })
    # No need to assert anything here as Faraday would complain about a request not being stubbed <3
    dispatch.call('build:finished', build)
  end


  def stub_http
    $http_stub ||= Faraday::Adapter::Test::Stubs.new
    Travis::Notifications::Handler::Webhook.http_client = Faraday.new do |f|
      f.request :url_encoded
      f.adapter :test, $http_stub
    end
  end
end
