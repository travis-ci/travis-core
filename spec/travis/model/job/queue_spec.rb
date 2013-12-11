require 'spec_helper'

describe 'Job::Queue' do
  def queue(*args)
    Job::Queue.new(*args)
  end

  before do
    Travis.config.queues = [
      { :queue => 'builds.rails', :slug => 'rails/rails' },
      { :queue => 'builds.osx', :os => 'osx'},
      { :queue => 'builds.cloudfoundry', :owner => 'cloudfoundry' },
      { :queue => 'builds.clojure', :language => 'clojure' },
      { :queue => 'builds.erlang', :language => 'erlang' },
    ]
    Job::Queue.instance_variable_set(:@queues, nil)
    Job::Queue.instance_variable_set(:@default, nil)
  end

  after do
    Travis.config.default_queue = 'builds.linux'
  end

  it 'returns builds.linux as the default queue' do
    Job::Queue.default.name.should == 'builds.linux'
  end

  it 'returns builds.common as the default queue if configured to in Travis.config' do
    Travis.config.default_queue = 'builds.common'
    Job::Queue.default.name.should == 'builds.common'
  end

  describe 'Queue.for' do
    it 'returns the default build queue when neither slug or language match the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci'))
      Job::Queue.for(job).name.should == 'builds.linux'
    end

    it 'returns the queue when slug matches the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'rails', :name => 'rails'))
      Job::Queue.for(job).name.should == 'builds.rails'
    end

    it 'returns the queue when language matches the given configuration hash' do
      job = stub('job', :config => { :language => 'clojure' }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci'))
      Job::Queue.for(job).name.should == 'builds.clojure'
    end

    it 'returns the queue when the owner matches the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'cloudfoundry', :name => 'bosh'))
      Job::Queue.for(job).name.should == 'builds.cloudfoundry'
    end

    it 'handles language being passed as an array gracefully' do
      job = stub('job', :config => { :language => ['clojure'] }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci'))
      Job::Queue.for(job).name.should == 'builds.clojure'
    end

    context 'when "os" value matches the given configuration hash' do
      it 'returns the matching queue' do
        job = stub('job', :config => { :os => 'osx'}, :repository => stub('travis-core', :owner_name => 'travis-ci', :name => 'bosh'))
        Job::Queue.for(job).name.should == 'builds.osx'
      end

      it 'returns the matching queue when language is also given' do
        job = stub('job', :config => {:language => 'clojure', :os => 'osx'}, :repository => stub('travis-core', :owner_name => 'travis-ci', :name => 'bosh'))
        Job::Queue.for(job).name.should == 'builds.osx'
      end
    end
  end

  describe 'Queue.queues' do
    it 'returns an array of Queues for the config hash' do
      rails, os, cloudfoundry, clojure, erlang = Job::Queue.send(:queues)

      rails.name.should == 'builds.rails'
      rails.slug.should == 'rails/rails'

      cloudfoundry.name.should == 'builds.cloudfoundry'
      cloudfoundry.owner.should == 'cloudfoundry'

      clojure.name.should == 'builds.clojure'
      clojure.language.should == 'clojure'
    end
  end

  describe 'matches?' do
    it "returns false when neither of slug or language match" do
      queue = queue('builds.linux',  nil, nil, nil)
      queue.send(:matches?, 'foo', 'foo/bar', 'COBOL').should be_false
    end

    it "returns true when the given owner matches" do
      queue = queue('builds.cloudfoundry', nil, 'cloudfoundry', nil)
      queue.send(:matches?, 'cloudfoundry', 'bosh', nil).should be_true
    end

    it "returns true when the given slug matches" do
      queue = queue('builds.rails', 'rails/rails', nil, nil)
      queue.send(:matches?, 'rails', 'rails', nil).should be_true
    end

    it "returns true when the given language matches" do
      queue = queue('builds.linux', nil, nil, 'clojure')
      queue.send(:matches?, nil, nil, 'clojure').should be_true
    end

    it 'returns true when os is missing' do
      queue = queue('builds.linux', nil, nil, 'clojure', nil)
      queue.send(:matches?, nil, nil, 'clojure', nil).should be_true
    end
  end
end
