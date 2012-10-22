require 'active_support/core_ext/numeric/time'

module Travis
  module Testing
    module Stubs
      autoload :Stub, 'travis/testing/stubs/stub'

      class << self
        include Stub

        def included(base)
          base.send(:instance_eval) do
            let(:repository) { stub_repository }
            let(:request)    { stub_request }
            let(:commit)     { stub_commit }
            let(:build)      { stub_build }
            let(:test)       { stub_test }
            let(:log)        { stub_log }
            let(:event)      { stub_event }
            let(:worker)     { stub_worker }
            let(:user)       { stub_user }
            let(:org)        { stub_org }
            let(:hook)       { stub_hook }
            let(:url)        { stub_url }
            let(:broadcast)  { stub_broadcast }
          end
        end
      end

      def stub_repository(attributes = {})
        Stubs.stub 'repository', attributes.reverse_merge(
          :id => 1,
          :owner_name => 'svenfuchs',
          :owner_email => 'svenfuchs@artweb-design.de',
          :name => 'minimal',
          :slug => 'svenfuchs/minimal',
          :description => 'the repo description',
          :url => 'http://github.com/svenfuchs/minimal',
          :source_url => 'git://github.com/svenfuchs/minimal.git',
          :key => stub_key,
          :admin => stub_user,
          :private? => false,
          :last_build_id => 1,
          :last_build_number => 2,
          :last_build_started_at => Time.now.utc - 60,
          :last_build_finished_at => Time.now.utc,
          :last_build_result => 0,
          :last_build_result_on => 0,
          :last_build_language => 'ruby',
          :last_build_duration => 60
        )
      end

      def stub_key(attributes = {})
        Stubs.stub 'key', attributes.reverse_merge(
          :id => 1,
          :public_key => '-----BEGIN PUBLIC KEY-----'
        )
      end

      def stub_request(attributes = {})
        Stubs.stub 'request', attributes.reverse_merge(
          :id => 1,
          :repository => stub_repository,
          :commit => stub_commit,
          :config => {},
          :event_type => 'push',
          :head_commit => 'head-commit',
          :base_commit => 'base-commit',
          :token => 'token',
          :comments_url => 'http://github.com/path/to/comments',
          :pull_request? => false,
          :result => :accepted
        )
      end

      def stub_commit(attributes = {})
        Stubs.stub 'commit', attributes.reverse_merge(
          :id => 1,
          :commit => '62aae5f70ceee39123ef',
          :branch => 'master',
          :ref => 'refs/master',
          :message => 'the commit message',
          :author_name => 'Sven Fuchs',
          :author_email => 'svenfuchs@artweb-design.de',
          :committer_name => 'Sven Fuchs',
          :committer_email => 'svenfuchs@artweb-design.de',
          :committed_at => Time.now.utc - 3600,
          :compare_url => 'https://github.com/svenfuchs/minimal/compare/master...develop',
          :config_url => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml',
          :pull_request? => false
        )
      end

      def stub_build(attributes = {})
        Stubs.stub 'build', attributes.reverse_merge(
          :id => 1,
          :repository_id => repository.id,
          :repository => repository,
          :request_id => request.id,
          :request => request,
          :commit_id => commit.id,
          :commit => commit,
          :matrix => [stub_test(:id => 1, :number => '2.1'), stub_test(:id => 2, :number => '2.2')],
          :matrix_ids => [1, 2],
          :number => 2,
          :config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
          :obfuscated_config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
          :result => 0,
          :result_message => 'Passed',
          :passed? => true,
          :failed? => false,
          :previous_result => 0,
          :previous_passed? => true,
          :state => 'finished',
          :started_at => Time.now.utc - 60,
          :finished_at => Time.now.utc,
          :duration => 60,
          :pull_request? => false,
          :queue => 'builds.common'
        )
      end

      def stub_test(attributes = {})
        Stubs.stub 'test', attributes.reverse_merge(
          :id => 1,
          :owner => stub_user,
          :repository_id => 1,
          :repository => repository,
          :source_id => 1,
          :request_id => 1,
          :commit_id => commit.id,
          :commit => commit,
          :log => log,
          :number => '2.1',
          :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
          :decrypted_config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
          :obfuscated_config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
          :result => 0,
          :state => :finished,
          :started? => true,
          :finished? => true,
          :queue => 'builds.common',
          :allow_failure => false,
          :started_at => Time.now.utc - 60,
          :finished_at => Time.now.utc,
          :sponsor => { 'name' => 'Railslove', 'url' => 'http://railslove.de' },
          :worker => 'ruby3.worker.travis-ci.org:travis-ruby-4',
          :tags => 'tag-a,tag-b'
        )
      end

      def stub_log(attributes = {})
        Stubs.stub 'log', attributes.reverse_merge(
          :class => Stubs.stub('class', :name => 'Artifact::Log'),
          :id => 1,
          :job_id => 1,
          :content => 'the test log'
        )
      end

      def stub_event(attributes = {})
        Stubs.stub 'event', attributes.reverse_merge(
          :id => 1,
          :repository_id => 1,
          :source => stub_request,
          :source_id => stub_request.id,
          :source_type => 'Request',
          :event => 'request:finished',
          :data => { 'result' => 'accepted' },
          :created_at => Time.now
        )
      end

      def stub_worker(attributes = {})
        Stubs.stub 'worker', attributes.reverse_merge(
          :id => 1,
          :name => 'ruby-1',
          :host => 'ruby-1.worker.travis-ci.org',
          :queue => 'builds.common',
          :state => 'created',
          :last_seen_at => Time.now.utc,
          :payload => nil,
          :last_error => nil
        )
      end

      def stub_user(attributes = {})
        Stubs.stub 'user', attributes.reverse_merge(
          :id => 1,
          :organizations => [org],
          :name => 'Sven Fuchs',
          :login => 'svenfuchs',
          :email => 'svenfuchs@artweb-design.de',
          :gravatar_id => '402602a60e500e85f2f5dc1ff3648ecb',
          :locale => 'de',
          :github_oauth_token => 'token',
          :syncing? => false,
          :is_syncing => false,
          :synced_at => Time.now.utc - 3600
        )
      end

      def stub_org(attributes = {})
        Stubs.stub 'org', attributes.reverse_merge(
          :id => 1,
          :login => 'travis-ci',
          :name => 'Travis CI',
          :email => 'contact@travis-ci.org'
        )
      end

      def stub_hook(attributes = {})
        Stubs.stub 'hook', attributes.reverse_merge(
          :id => stub_repository.id,
          :repository => stub_repository,
          :owner_name => 'travis-ci',
          :name => 'travis-ci',
          :description => 'description',
          :active => true,
          :private => false
        )
      end

      def stub_url(attributes = {})
        Stubs.stub 'url', attributes.reverse_merge(
          :id => 1,
          :short_url => 'http://trvs.io/short'
        )
      end

      def stub_broadcast(attributes = {})
        Stubs.stub 'broadcast', attributes.reverse_merge(
          :id => 1,
          :message => 'message'
        )
      end
    end
  end
end

