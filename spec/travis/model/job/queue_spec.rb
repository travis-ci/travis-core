require 'spec_helper'

describe 'Job::Queue' do
  def queue(*args)
    Job::Queue.new(*args)
  end

  let(:the_past) { Time.parse("1982-06-23") }
  let(:recently) { 7.days.ago }

  before do
    Travis.config.queues = [
      { :queue => 'builds.rails', :slug => 'rails/rails' },
      { :queue => 'builds.mac_osx', :os => 'osx' },
      { :queue => 'builds.docker', :sudo => false },
      { :queue => 'builds.education', :education => true },
      { :queue => 'builds.cloudfoundry', :owner => 'cloudfoundry' },
      { :queue => 'builds.clojure', :language => 'clojure' },
      { :queue => 'builds.erlang', :language => 'erlang' },
      { :queue => 'builds.openstack', :dist => 'trusty' },
    ]
    Job::Queue.instance_variable_set(:@queues, nil)
    Job::Queue.instance_variable_set(:@default, nil)
    Travis::Features.stubs(:owner_active?).returns(true)
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
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci', :owner => stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.linux'
    end

    it 'returns the queue when slug matches the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'rails', :name => 'rails', :owner => stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.rails'
    end

    it 'returns the queue when language matches the given configuration hash' do
      job = stub('job', :config => { :language => 'clojure' }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci', :owner => stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.clojure'
    end

    it 'returns the queue when the owner matches the given configuration hash' do
      job = stub('job', :config => {}, :repository => stub('repository', :owner_name => 'cloudfoundry', :name => 'bosh', :owner => stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.cloudfoundry'
    end

    it 'returns the queue when sudo requirements matches the given configuration hash' do
      job = stub('job', :config => { sudo: false }, :repository => stub('repository', :owner_name => 'markronson', :name => 'recordcollection', :owner => stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.docker'
    end

    it 'returns the queue when education requirements matches the given configuration hash' do
      Travis::Github::Education.stubs(:education_queue?).returns(true)
      owner = stub('owner', :education => true)
      job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'markronson', :name => 'recordcollection', :owner => owner, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.education'
    end

    it 'does not return education queue if feature flag is disabled' do
      Travis::Github::Education.stubs(:education_queue?).returns(false)
      owner = stub('owner', :education => true)
      job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'markronson', :name => 'recordcollection', :owner => owner, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.linux'
    end

    it 'returns the queue when education requirements matches, ignoring configuration hash' do
      Travis::Github::Education.stubs(:education_queue?).returns(true)
      owner = stub('owner', :education => true)
      job = stub('job', :config => { :os => 'osx' }, :repository => stub('repository', :owner_name => 'markronson', :name => 'recordcollection', :owner => owner, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.education'
    end

    it 'handles language being passed as an array gracefully' do
      job = stub('job', :config => { :language => ['clojure'] }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-ci', :owner => stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.clojure'
    end

    context 'when "os" value matches the given configuration hash' do
      it 'returns the matching queue' do
        job = stub('job', :config => { :os => 'osx'}, :repository => stub('travis-core', :owner_name => 'travis-ci', :name => 'bosh', :owner => stub, :created_at => the_past))
        Job::Queue.for(job).name.should == 'builds.mac_osx'
      end

      it 'returns the matching queue when language is also given' do
        job = stub('job', :config => {:language => 'clojure', :os => 'osx'}, :repository => stub('travis-core', :owner_name => 'travis-ci', :name => 'bosh', :owner => stub, :created_at => the_past))
        Job::Queue.for(job).name.should == 'builds.mac_osx'
      end
    end

    context 'when "docker_default_queue" feature is active' do
      before do
        Travis::Features.stubs(:feature_active?).with(:docker_default_queue).returns(true)
        Travis::Features.stubs(:feature_active?).with(:education).returns(true)
      end

      it 'returns "builds.docker" when the repo created_at is nil' do
        job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => nil))
        Job::Queue.for(job).name.should == 'builds.docker'
      end

      it 'returns "builds.docker" when the repo created_at is greater than the cutoff' do
        Travis.config.docker_default_queue_cutoff = recently.to_s
        job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => Time.now))
        Job::Queue.for(job).name.should == 'builds.docker'
      end
    end
  end

  context 'when "sudo" value matches the given configuration hash' do
    it 'returns the matching queue' do
      job = stub('job', config: { sudo: false }, repository: stub('travis-core', owner_name: 'travis-ci', name: 'travis-core', owner: stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.docker'
    end

    it 'returns the matching queue when language is also given' do
      job = stub('job', config: { language: 'clojure', sudo: false }, repository: stub('travis-core', owner_name: 'travis-ci', name: 'travis-core', owner: stub, :created_at => the_past))
      Job::Queue.for(job).name.should == 'builds.docker'
    end
  end

  describe 'Queue.queues' do
    it 'returns an array of Queues for the config hash' do
      rails, os, docker, edu, cloudfoundry, clojure, erlang = Job::Queue.send(:queues)

      rails.name.should == 'builds.rails'
      rails.slug.should == 'rails/rails'

      docker.name.should == 'builds.docker'
      docker.sudo.should == false

      edu.name.should == 'builds.education'
      edu.education.should == true

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

    it 'returns true when sudo is false' do
      queue = queue('builds.docker', nil, nil, nil, nil, false)
      queue.send(:matches?, nil, nil, nil, nil, false).should be_true
    end

    it 'returns false when sudo is true' do
      queue = queue('builds.docker', nil, nil, nil, nil, false)
      queue.send(:matches?, nil, nil, nil, nil, true).should be_false
    end

    it 'returns false when sudo is nil' do
      queue = queue('builds.docker', nil, nil, nil, nil, false)
      queue.send(:matches?, nil, nil, nil, nil, nil).should be_false
    end

    it 'returns true when dist matches' do
      queue = queue('builds.openstack', nil, nil, nil, nil, false, 'trusty')
      queue.send(:matches?, nil, nil, nil, nil, true, 'trusty').should be_true
    end

    it 'returns false when dist does not match' do
      queue = queue('builds.docker', nil, nil, nil, nil, false, 'precise')
      queue.send(:matches?, nil, nil, nil, nil, nil, 'trusty').should be_false
    end
  end
end
