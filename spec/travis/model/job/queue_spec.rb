require 'spec_helper'

describe 'Job::Queue' do
  def queue(*args)
    Job::Queue.new(*args)
  end

  before do
    Travis.config.queues = [
      { :queue => 'builds.rails', :slug => 'rails/rails' },
      { :queue => 'builds.clojure', :language => 'clojure' },
      { :queue => 'builds.erlang', :target => 'erlang', :language => 'erlang' },
    ]
    Job::Queue.instance_variable_set(:@queues, nil)
  end

  it 'queues returns an array of Queues for the config hash' do
    rails, clojure, erlang = Job::Queue.queues

    rails.name.should == 'builds.rails'
    rails.slug.should == 'rails/rails'

    clojure.name.should == 'builds.clojure'
    clojure.language.should == 'clojure'

    erlang.name.should == 'builds.erlang'
    erlang.target.should == 'erlang'
  end

  describe 'Queue.for' do
    it 'returns the default queue when neither slug or target match the given configuration hash' do
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

    # it 'returns the queue when target matches the given configuration hash' do
    #   job = stub('job', :config => { :target => 'erlang' }, :repository => stub('repository', :slug => 'travis-ci/travis-ci'))
    #   Job::Queue.for(job).name.should == 'erlang'
    # end
  end

  describe 'matches?' do
    it "returns false when none of slug, target or language match" do
      queue = queue('builds.common',  nil, nil, nil)
      queue.matches?('foo/bar', 'worker-on-mars', 'COBOL').should be_false
    end

    it "returns true when the given slug matches" do
      queue = queue('builds.rails', 'rails/rails', nil)
      queue.matches?('rails/rails', nil, nil).should be_true
    end

    it "returns true when the given language matches" do
      queue = queue('builds.common', nil, nil, 'clojure')
      queue.matches?(nil, nil, 'clojure').should be_true
    end

    # it "returns true when the given target matches" do
    #   queue = queue('builds.erlang', nil, 'erlang', nil)
    #   queue.matches?(nil, 'erlang', nil).should be_true
    # end
  end
end
