require 'spec_helper'
require 'rack'

describe Travis::Task::Webhook do
  include Travis::Testing::Stubs, Support::Formats

  let(:http)    { Faraday::Adapter::Test::Stubs.new }
  let(:client)  { Faraday.new { |f| f.request :url_encoded; f.adapter :test, http } }
  let(:io)      { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:webhook]
    Travis::Task::Webhook.any_instance.stubs(:http).returns(client)
    build.config[:notifications] = { :webhooks => 'http://example.com' }
  end

  def run(targets, payload)
    Travis::Task::Webhook.new(payload, :targets => targets, :token => build.request.token).run
  end

  it 'sends webhook notifications to a url given as a string' do
    target = 'http://evome.fr/notifications'
    build.config[:notifications][:webhooks] = target
    verify_notifications_on_finish(build, target)
  end

  it 'sends webhook notifications to the urls given as an array' do
    targets = ['http://evome.fr/notifications', 'http://example.com/']
    build.config[:notifications][:webhooks] = targets
    verify_notifications_on_finish(build, *targets)
  end

  it 'sends no webhook if the given url is blank' do
    build.config[:notifications][:webhooks] = ''
    # No need to assert anything here as Faraday would complain about a request not being stubbed <3
    verify_notifications_on_finish(build)
  end

  it 'sends webhook notifications to a url given at a "urls" key' do
    target = 'http://evome.fr/notifications'
    build.config[:notifications][:webhooks] = {:urls => target}
    verify_notifications_on_finish(build, target)
  end

  it 'sends webhook notifications to the urls given at a "urls" key' do
    targets = ['http://evome.fr/notifications', 'http://example.com/']
    build.config[:notifications][:webhooks] = {:urls => targets}
    verify_notifications_on_finish(build, *targets)
  end

  it 'sends webhook notifications on start to a url given at a "urls" key' do
    target = 'http://evome.fr/notifications'
    build.config[:notifications][:webhooks] = {:on_start => true, :urls => target}
    verify_notifications_on_start(build, target)
    verify_notifications_on_finish(build, target)
  end

  it 'sends webhook notifications on start when configured as "always"' do
    target = 'http://evome.fr/notifications'
    build.config[:notifications][:webhooks] = {:on_start => :always, :urls => target}
    verify_notifications_on_start(build, target)
    verify_notifications_on_finish(build, target)
  end

  it 'sends webhook notifications on start to the urls given as an array' do
    targets = ['http://evome.fr/notifications', 'http://example.com/']
    build.config[:notifications][:webhooks] = {:on_start => true, :urls => targets}
    verify_notifications_on_start(build, *targets)
    verify_notifications_on_finish(build, *targets)
  end

  it 'sends no webhook on start by default' do
    build.config[:notifications][:webhooks] = {:on_start => true}
    verify_notifications_on_start(build)
  end

  def verify_notifications_on_start(build, *urls)
    verify_notifications('build:started', build, *urls)
  end

  def verify_notifications_on_finish(build, *urls)
    verify_notifications('build:finished', build, *urls)
  end

  def verify_notifications(event, build, *urls)
    payload = Travis::Api.data(build, :for => 'webhook', :type => 'build/finished', :version => 'v1')

    urls.each do |url|
      uri = URI.parse(url)
      http.post uri.path do |env|
        env[:url].host.should == uri.host
        env[:url].path.should == uri.path
        env[:request_headers]['Authorization'].should == authorization_for(build)

        payload_from(env).keys.sort.should == payload.keys.map(&:to_s).sort
      end
    end

    run(urls, payload)
    http.verify_stubbed_calls
  end

  def payload_from(env)
    JSON.parse(Rack::Utils.parse_query(env[:body])['payload'])
  end

  def authorization_for(build)
    Digest::SHA2.hexdigest(build.repository.slug + build.request.token)
  end
end
