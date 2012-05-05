module Support
  module Stubs
    def self.included(base)
      base.send(:instance_eval) do
        let(:repository) do
          stub 'repository', {
            :id => 1,
            :owner_name => 'svenfuchs',
            :name => 'minimal',
            :slug => 'svenfuchs/minimal',
            :description => 'the repo description',
            :url => 'http://github.com/svenfuchs/minimal',
            :source_url => 'git://github.com/svenfuchs/minimal.git',
            :key => stub('key', :public_key => '-----BEGIN PUBLIC KEY-----'),
            :last_build_id => 1,
            :last_build_number => 2,
            :last_build_started_at => Time.now.utc - 1.minute,
            :last_build_finished_at => Time.now.utc,
            :last_build_result => 0,
            :last_build_language => 'ruby',
            :last_build_duration => 60
          }
        end

        let(:request) do
          stub 'request', {
            :event_type => 'push'
          }
        end

        let(:commit) do
          stub 'commit', {
            :commit => '62aae5f70ceee39123ef',
            :branch => 'master',
            :message => 'the commit message',
            :author_name => 'Sven Fuchs',
            :author_email => 'svenfuchs@artweb-design.de',
            :committer_name => 'Sven Fuchs',
            :committer_email => 'svenfuchs@artweb-design.de',
            :committed_at => Time.now.utc - 1.hour,
            :compare_url => 'https://github.com/svenfuchs/minimal/compare/master...develop',
            :config_url => 'https://raw.github.com/svenfuchs/minimal/62aae5f70ceee39123ef/.travis.yml',
          }
        end

        let(:build) do
          stub 'build', {
            :id => 1,
            :repository_id => repository.id,
            :repository => repository,
            :request => request,
            :commit => commit,
            :matrix => [test],
            :number => 2,
            :config => { 'rvm' => ['1.8.7', '1.9.2'], 'gemfile' => ['test/Gemfile.rails-2.3.x', 'test/Gemfile.rails-3.0.x'] },
            :result => 0,
            :result_message => 'Passed',
            :state => 'finished',
            :started_at => Time.now.utc - 1.minute,
            :finished_at => Time.now.utc,
            :duration => 60,
          }
        end

        let(:test) do
          stub 'test', {
            :id => 1,
            :repository_id => 1,
            :repository => repository,
            :source_id => 1,
            :commit => commit,
            :log => stub('log', :content => 'the test log'),
            :number => '2.1',
            :config => { 'rvm' => '1.8.7', 'gemfile' => 'test/Gemfile.rails-2.3.x' },
            :result => 0,
            :state => :finished,
            :started? => true,
            :finished? => true,
            :queue => 'builds.common',
            :allow_failure => false,
            :started_at => Time.now.utc - 1.minute,
            :finished_at => Time.now.utc,
            :sponsor => { 'name' => 'Railslove', 'url' => 'http://railslove.de' },
            :worker => 'ruby3.worker.travis-ci.org:travis-ruby-4',
          }
        end

        let(:worker) do
          stub 'worker', {
            :id => 1,
            :name => 'ruby-1',
            :host => 'ruby-1.worker.travis-ci.org',
            :state => 'created',
            :last_seen_at => Time.now.utc,
            :payload => nil,
            :last_error => nil
          }
        end
      end
    end
  end
end
