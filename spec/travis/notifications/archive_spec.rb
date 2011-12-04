require 'spec_helper'
require 'support/active_record'
require 'support/formats'
require 'json'

describe Travis::Notifications::Archive do
  include Support::Formats

  let(:since)    { Time.utc(2011, 1, 2) }
  let(:archiver) { Travis::Notifications::Archive.new }
  let(:build)    { Factory(:build, :created_at => Time.utc(2011, 1, 1), :config => { :rvm => ['1.9.2', 'rbx'] }) }

  before do
    # Travis.config.notifications = [:archive]
  end

  describe 'archive' do
    before :each do
      archiver.stubs(:store)
    end

    it 'stores the build to the storage' do
      archiver.expects(:store).with(build)
      archiver.send(:archive, build)
    end

    it 'sets the build to be archived' do
      archiver.send(:archive, build)
      build.reload.archived_at.should_not be_nil
    end
  end

  describe 'json_for' do
    it 'returns archival json for the complete build' do
      build.matrix.first.log.update_attributes!(:content => 'the log')
      build.reload
      test = build.matrix.first
      repository = build.repository

      data = JSON.parse(archiver.send(:json_for, build))
      data.except('matrix', 'repository').should == {
        'id' => build.id,
        'number' => build.number,
        'started_at' => json_format_time(build.started_at),
        'finished_at' => json_format_time(build.finished_at),
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
end
