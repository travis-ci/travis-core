require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Worker do
  include Support::ActiveRecord

  let(:worker)  { Travis::Notifications::Worker.new }
  let(:payload) { 'the-payload' }

  before do
    Travis.config.queues = [
      { :queue => 'builds.rails', :slug => 'rails/rails' },
      { :queue => 'builds.clojure', :language => 'clojure' },
      { :queue => 'builds.erlang', :target => 'erlang', :language => 'erlang' },
    ]
    Travis::Notifications::Worker.instance_variable_set(:@queues, nil)
  end

  it 'queues returns an array of Queues for the config hash' do
    rails, clojure, erlang = Travis::Notifications::Worker.send(:queues)

    rails.name.should == 'builds.rails'
    rails.slug.should == 'rails/rails'

    clojure.name.should == 'builds.clojure'
    clojure.language.should == 'clojure'

    erlang.name.should == 'builds.erlang'
    erlang.target.should == 'erlang'
  end

  describe 'queue_for' do
    it 'returns false when neither slug or target match the given configuration hash' do
      build = Factory(:build)
      worker.send(:queue_for, build).name.should == 'builds.common'
    end

    it 'returns the queue when slug matches the given configuration hash' do
      build = Factory(:build, :repository => Factory(:repository, :owner_name => 'rails', :name => 'rails'))
      worker.send(:queue_for, build).name.should == 'builds.rails'
    end

    it 'returns the queue when target matches the given configuration hash' do
      build = Factory(:build, :repository => Factory(:repository), :config => { :language => 'clojure' })
      worker.send(:queue_for, build).name.should == 'builds.clojure'
    end

    # it 'returns the queue when language matches the given configuration hash' do
    #   build = Factory(:build, :repository => Factory(:repository), :config => { :target => 'erlang' })
    #   worker.send(:queue_for, build).name.should == 'erlang'
    # end
  end

  describe 'notify' do
    let(:job)     { Factory(:request).job }

    before :each do
      Travis::Notifications::Worker.stubs(:payload_for).returns(payload)
      Travis::Amqp.stubs(:publish)
    end

    it 'generates a payload for the given job' do
      Travis::Notifications::Worker.stubs(:payload_for).with(job, :queue => 'builds.common')
      worker.notify(:start, job)
    end

    it 'adds the payload to the given queue' do
      Travis::Amqp.expects(:publish).with('builds.common', payload)
      worker.notify(:start, job)
    end
  end

  describe "#enqueue" do
    let(:job) { Factory.build(:test) }

    before(:each) do
      Travis::Notifications::Worker.stubs(:payload_for).returns(payload)
      Travis::Amqp.stubs(:publish)
    end

    it "updates the given job's queue" do
      queue = Travis::Notifications::Worker.queue_for(job)
      worker.enqueue(job)

      job.queue.should eql(queue.name)
    end
  end
end
