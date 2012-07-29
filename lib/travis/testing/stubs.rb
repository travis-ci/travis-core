require 'active_support/core_ext/numeric/time'

module Travis
  module Testing
    module Stubs
      def self.included(base)
        base.send(:instance_eval) do
          let(:repository) { stub_repository }
          let(:request)    { stub_request }
          let(:commit)     { stub_commit }
          let(:build)      { stub_build }
          let(:test)       { stub_test }
          let(:log)        { stub_log }
          let(:worker)     { stub_worker }
          let(:user)       { stub_user }
          let(:url)        { stub_url }
        end
      end

      def stub_repository(attributes = {})
        stub 'repository', attributes.reverse_merge(
          :class => stub('Repository', :name => 'Repository', :base_class => stub('Repository', :name => 'Repository')),
          :id => 1,
          :owner_name => 'svenfuchs',
          :owner_email => 'svenfuchs@artweb-design.de',
          :name => 'minimal',
          :slug => 'svenfuchs/minimal',
          :description => 'the repo description',
          :url => 'http://github.com/svenfuchs/minimal',
          :source_url => 'git://github.com/svenfuchs/minimal.git',
          :key => stub('key', :id => 1, :public_key => '-----BEGIN PUBLIC KEY-----'),
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

      def stub_request(attributes = {})
        stub 'request', attributes.reverse_merge(
          :id => 1,
          :repository => stub_repository(),
          :commit => stub_commit(),
          :config => {},
          :event_type => 'push',
          :head_commit => 'head-commit',
          :base_commit => 'base-commit',
          :token => 'token',
          :comments_url => 'http://github.com/path/to/comments'
        )
      end

      def stub_commit(attributes = {})
        stub 'commit', attributes.reverse_merge(
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
        stub 'build', attributes.reverse_merge(
          :class => stub('Build', :name => 'Build', :base_class => stub('Build', :name => 'Build')),
          :id => 1,
          :repository_id => repository.id,
          :repository => repository,
          :request_id => request.id,
          :request => request,
          :commit_id => commit.id,
          :commit => commit,
          :matrix => [stub_test(:id => 1, :number => '2.1'), stub_test(:id => 2, :number => '2.2')],
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
        stub 'test', attributes.reverse_merge(
          :class => stub('Job::Test', :name => 'Job::Test', :base_class => stub('Job', :name => 'Job')),
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
        stub 'log', attributes.reverse_merge(
          :id => 1,
          :job_id => 1,
          :class => stub('class', :name => 'Artifact::Log'),
          :content => 'the test log'
        )
      end

      def stub_worker(attributes = {})
        stub 'worker', attributes.reverse_merge(
          :class => stub('Worker', :name => 'Worker'),
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
        stub 'user', attributes.reverse_merge(
          :class => stub('User', :name => 'User', :base_class => stub('User', :name => 'User')),
          :id => 1,
          :organizations => [],
          :name => 'Sven Fuchs',
          :login => 'svenfuchs',
          :email => 'svenfuchs@artweb-design.de',
          :gravatar_id => '402602a60e500e85f2f5dc1ff3648ecb',
          :locale => 'de',
          :github_oauth_token => 'token',
          :is_syncing => false,
          :synced_at => Time.now.utc - 3600
        )
      end

      def stub_url(attributes = {})
        stub 'url', attributes.reverse_merge(
          :class => stub('Url', :name => 'Url'),
          :id => 1,
          :short_url => 'http://trvs.io/short'
        )
      end
    end
  end
end

