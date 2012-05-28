require 'spec_helper'
require 'support/active_record'
require 'support/formats'
require 'json'

describe Travis::Notifications::Handler::Archive do
  include Support::ActiveRecord
  include Support::Formats

  let(:http)     { Faraday::Adapter::Test::Stubs.new }
  let(:client)   { Faraday.new { |f| f.request :url_encoded; f.adapter(:test, http) } }

  let(:handler)  { Travis::Notifications::Handler::Archive.new }
  let(:build)    { Factory(:build, :created_at => Time.utc(2011, 1, 1), :config => { :rvm => ['1.9.2', 'rbx'] }) }
  let(:io)       { StringIO.new }
  let(:payload)  { Travis::Notifications::Handler::Archive.payload_for(build) }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:archive]
    Travis.config.archive = { :host => 'host', :username => 'username', :password => 'password' }

    handler.stubs(:http_client).returns(client)
  end

  def archive!
    handler.notify('build:finished', build)
  end

  it 'build:started does archive the build' do
    Travis::Notifications::Handler::Archive.any_instance.expects(:archive).never
    Travis::Notifications.dispatch('build:started', build)
  end

  it 'build:finish archives the build' do
    Travis::Notifications::Handler::Archive.any_instance.expects(:archive)
    Travis::Notifications.dispatch('build:finished', build)
  end

  describe 'notify' do
    before :each do
      http.put("/builds/#{build.id}") {[ 200, {}, 'ok' ]}
    end

    it 'stores the build payload to the storage' do
      archive!
      http.verify_stubbed_calls
    end

    it 'sets the build to be archived' do
      archive!
      build.reload.archived_at.should_not be_nil
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      http.put("/builds/#{build.id}") {[ 200, {}, 'ok' ]}
      archive!
      io.string.should include("[archive] Successfully archived http://username:password@host/builds/#{build.id}")
    end

    it 'warns about a failed request' do
      http.put("/builds/#{build.id}") {[ 403, {}, 'nono.' ]}
      archive!
      io.string.should include(%([archive] Could not archive to http://username:password@host/builds/#{build.id}. Status: 403 (\"nono.\")))
    end
  end
end
