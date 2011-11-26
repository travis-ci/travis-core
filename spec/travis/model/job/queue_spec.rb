require 'spec_helper'

describe 'Job::Queue' do
  def queue(*args)
    Job::Queue.new(*args)
  end

  before do
    Travis.config.queues = [
      { :queue => 'builds.rails', :slug => 'rails/rails' },
      { :queue => 'builds.clojure', :language => 'clojure' },
      { :queue => 'builds.erlang', :language => 'erlang' },
    ]
    Job::Queue.instance_variable_set(:@queues, nil)
  end

  it 'queues returns an array of Queues for the config hash' do
    rails, clojure, erlang = Job::Queue.queues

    rails.name.should == 'builds.rails'
    rails.slug.should == 'rails/rails'

    clojure.name.should == 'builds.clojure'
    clojure.language.should == 'clojure'
  end

  describe 'Queue.for' do
    it 'returns the default queue when neither slug or language match the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :slug => 'travis-ci/travis-ci'))
      Job::Queue.for(job).name.should == 'builds.common'
    end

    it 'returns the queue when slug matches the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :slug => 'rails/rails'))
      Job::Queue.for(job).name.should == 'builds.rails'
    end

    it 'returns the queue when language matches the given configuration hash' do
      job = stub('job', :config => { :language => 'clojure' }, :repository => stub('repository', :slug => 'travis-ci/travis-ci'))
      Job::Queue.for(job).name.should == 'builds.clojure'
    end
  end

  describe 'matches?' do
    it "returns false when neither of slug or language match" do
      queue = queue('builds.common',  nil, nil)
      queue.matches?('foo/bar', 'COBOL').should be_false
    end

    it "returns true when the given slug matches" do
      queue = queue('builds.rails', 'rails/rails')
      queue.matches?('rails/rails', nil).should be_true
    end

    it "returns true when the given language matches" do
      queue = queue('builds.common', nil, 'clojure')
      queue.matches?(nil, 'clojure').should be_true
    end
  end
end
