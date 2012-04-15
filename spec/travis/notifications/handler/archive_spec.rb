require 'spec_helper'
require 'support/active_record'
require 'support/formats'
require 'json'

describe Travis::Notifications::Handler::Archive do
  include Support::ActiveRecord
  include Support::Formats

  let(:http)     { Faraday::Adapter::Test::Stubs.new }
  let(:client)   { Faraday.new { |f| f.request :url_encoded; f.adapter(:test, http) } }
  let(:archive)  { Travis::Notifications::Handler::Archive.new }
  let(:build)    { Factory(:build, :created_at => Time.utc(2011, 1, 1), :config => { :rvm => ['1.9.2', 'rbx'] }) }
  let(:io)       { StringIO.new }

  before do
    Travis.logger = Logger.new(io)
    Travis.config.notifications = [:archive]
    archive.stubs(:http_client).returns(client)
  end

  it 'build:finish archives the build' do
    Travis::Notifications::Handler::Archive.any_instance.expects(:archive).with(build)
    Travis::Notifications.dispatch('build:finished', build)
  end

  describe 'archive' do
    before :each do
      archive.stubs(:store).returns(true)
    end

    it 'stores the build to the storage' do
      archive.expects(:store).with(build)
      archive.send(:archive, build)
    end

    it 'sets the build to be archived' do
      archive.send(:archive, build)
      build.reload.archived_at.should_not be_nil
    end
  end

  describe 'json_for' do
    it 'returns archival json for the complete build' do
      build.matrix.first.log.update_attributes!(:content => 'the log')
      build.reload
      test = build.matrix.first
      repository = build.repository

      data = JSON.parse(archive.send(:json_for, build))
      data.except('matrix', 'repository').should == {
        'id' => build.id,
        'number' => build.number,
        'started_at' => json_format_time(build.started_at),
        'finished_at' => json_format_time(build.finished_at),
        'duration' => nil,
        'config' => { 'rvm' => ['1.9.2', 'rbx'] },
        'result' => 0,
        'commit' => '62aae5f70ceee39123ef',
        'branch' => 'master',
        'message' => 'the commit message',
        'committed_at' => '2011-11-11T11:11:11Z',
        'committer_name' => 'Sven Fuchs',
        'committer_email' => 'svenfuchs@artweb-design.de',
        'author_name' => 'Sven Fuchs',
        'author_email' => 'svenfuchs@artweb-design.de',
      }
      data['matrix'].first.should == {
        'id' => test.id,
        'number' => test.number,
        'config' => { 'rvm' => '1.9.2' },
        'started_at' => json_format_time(test.started_at),
        'finished_at' => json_format_time(test.finished_at),
        'log' => 'the log'
      }
      data['repository'].should == {
        'id' => build.repository_id,
        'slug' => 'svenfuchs/minimal',
      }
    end
  end

  describe 'logging' do
    it 'logs a successful request' do
      archive.stubs(:url_for).returns('http://example.com/builds/1')
      http.put('/builds/1') {[ 200, {}, 'nono.' ]}
      archive.notify('build:finished', build)
      io.string.should include('[archive] Successfully archived http://example.com/builds/1')
    end

    it 'warns about a failed request' do
      archive.stubs(:url_for).returns('http://example.com/builds/1')
      http.put('/builds/1') {[ 403, {}, 'nono.' ]}
      archive.notify('build:finished', build)
      io.string.should include('[archive] Could not archive to http://example.com/builds/1. Status: 403 ("nono.")')
    end
  end
end
