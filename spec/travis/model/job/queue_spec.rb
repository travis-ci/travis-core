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

  describe 'Queue.sudo_detected?' do
    [
      [{ script: 'sudo echo' }, true],
      [{ bogus: 'sudo echo' }, false],
      [{ before_install: ['# no sudo', 'ping -c 1 google.com'] }, true],
      [{ before_script: ['echo ; echo ; echo ; sudo echo ; echo'] }, true],
      [{ install: '# no sudo needed here' }, false],
    ].each do |config, expected|
      it "returns #{expected} for #{config}" do
        Job::Queue.sudo_detected?(config).should == expected
      end
    end
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

      it 'returns "builds.docker" when sudo: nil and the repo created_at is nil' do
        job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => nil))
        Job::Queue.for(job).name.should == 'builds.docker'
      end

      it 'returns "builds.docker" when sudo: nil and the repo created_at is after cutoff' do
        Travis.config.docker_default_queue_cutoff = recently.to_s
        job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => Time.now))
        Job::Queue.for(job).name.should == 'builds.docker'
      end

      it 'returns "builds.linux" when sudo: nil and the repo created_at is before cutoff' do
        Travis.config.docker_default_queue_cutoff = recently.to_s
        job = stub('job', :config => { }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => recently - 7.days))
        Job::Queue.for(job).name.should == 'builds.linux'
      end

      it 'returns "builds.linux" when sudo: nil and the repo created_at is after cutoff and sudo is detected' do
        Travis.config.docker_default_queue_cutoff = recently.to_s
        job = stub('job', :config => { script: 'sudo echo whatever' }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => recently - 7.days))
        Job::Queue.for(job).name.should == 'builds.linux'
      end

      it 'returns "builds.docker" when sudo: false and the repo created_at is nil' do
        job = stub('job', :config => { sudo: false }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => nil))
        Job::Queue.for(job).name.should == 'builds.docker'
      end

      it 'returns "builds.docker" when sudo: false and the repo created_at is after cutoff' do
        Travis.config.docker_default_queue_cutoff = recently.to_s
        job = stub('job', :config => { sudo: false }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => Time.now))
        Job::Queue.for(job).name.should == 'builds.docker'
      end

      it 'returns "builds.docker" when sudo: false and the repo created_at is before cutoff' do
        Travis.config.docker_default_queue_cutoff = recently.to_s
        job = stub('job', :config => { sudo: false }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => recently - 7.days))
        Job::Queue.for(job).name.should == 'builds.docker'
      end

      [true, 'required'].each do |sudo|
        it %{returns "builds.linux" when sudo: #{sudo} and the repo created_at is nil} do
          Travis.config.docker_default_queue_cutoff = recently.to_s
          job = stub('job', :config => { sudo: sudo }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => nil))
          Job::Queue.for(job).name.should == 'builds.linux'
        end

        it %{returns "builds.linux" when sudo: #{sudo} and the repo created_at is after cutoff} do
          Travis.config.docker_default_queue_cutoff = recently.to_s
          job = stub('job', :config => { sudo: sudo }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => nil))
          Job::Queue.for(job).name.should == 'builds.linux'
        end

        it %{returns "builds.linux" when sudo: #{sudo} and the repo created_at is before cutoff} do
          Travis.config.docker_default_queue_cutoff = recently.to_s
          job = stub('job', :config => { sudo: sudo }, :repository => stub('repository', :owner_name => 'travis-ci', :name => 'travis-core', :owner => stub, :created_at => nil))
          Job::Queue.for(job).name.should == 'builds.linux'
        end
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
      rails.attrs[:slug].should == 'rails/rails'

      docker.name.should == 'builds.docker'
      docker.attrs[:sudo].should == false

      edu.name.should == 'builds.education'
      edu.attrs[:education].should == true

      cloudfoundry.name.should == 'builds.cloudfoundry'
      cloudfoundry.attrs[:owner].should == 'cloudfoundry'

      clojure.name.should == 'builds.clojure'
      clojure.attrs[:language].should == 'clojure'
    end
  end
end
