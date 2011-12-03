require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Webhook do
  include Support::ActiveRecord

  let(:http) { Faraday::Adapter::Test::Stubs.new }
  let(:io)   { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:webhook]

    Travis::Notifications::Webhook.http_client = Faraday.new do |f|
      f.request :url_encoded
      f.adapter :test, http
    end
  end

  let(:dispatch) { lambda { |event, object| Travis::Notifications.dispatch(event, object) } }

  it 'sends webhook notifications to the urls given as an array' do
    targets = ['http://evome.fr/notifications', 'http://example.com/']
    build = Factory(:build, :config => { 'notifications' => { 'webhooks' => targets } })
    dispatch.should post_webhooks_on(http, 'build:finished', build, :to => targets)
  end

  it 'sends webhook notifications to a url given as a string' do
    target = 'http://evome.fr/notifications'
    build = Factory(:build, :config => { 'notifications' => { 'webhooks' => target } })
    dispatch.should post_webhooks_on(http, 'build:finished', build, :to => ['http://evome.fr/notifications'])
  end

  it 'sends no webhook if the given url is blank' do
    build = Factory(:build, :config => { 'notifications' => { 'webhooks' => '' } })
    # No need to assert anything here as Faraday would complain about a request not being stubbed <3
    dispatch.call('build:finished', build)
  end

  it 'logs a warning if the post request was not successful' do
    build = Factory(:build, :config => { 'notifications' => { 'webhooks' => 'http://example.com/' } })
    http.post('/') {[ 403, {}, 'nono.' ]}
    dispatch.call('build:finished', build)
    io.string.should include('[webhook] Could not notify http://example.com/. Status: 403, body: "nono."')
  end
end

