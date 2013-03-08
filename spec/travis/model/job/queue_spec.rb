require 'spec_helper'

describe 'Job::Queue' do
  def queue(*args)
    Job::Queue.new(*args)
  end

  before do
    Travis.config.queues = [
      { :queue => 'builds.rails', :slug => 'rails/rails' },
      { :queue => 'builds.cloudfoundry', :owner => 'cloudfoundry' },
      { :queue => 'builds.clojure', :language => 'clojure' },
      { :queue => 'builds.erlang', :language => 'erlang' },
    ]
    Job::Queue.instance_variable_set(:@queues, nil)
  end

  describe 'Queue.for' do
    it 'returns the default build queue when neither slug or language match the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci'))
      Job::Queue.for(job).name.should == 'builds.common'
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
  end

  describe 'Queue.queues' do
    it 'returns an array of Queues for the config hash' do
      rails, cloudfoundry, clojure, erlang = Job::Queue.send(:queues)

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
      queue = queue('builds.common',  nil, nil, nil)
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
      queue = queue('builds.common', nil, nil, 'clojure')
      queue.send(:matches?, nil, nil, 'clojure').should be_true
    end
  end
end
