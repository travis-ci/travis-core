require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::Worker::Queue do
  include Support::ActiveRecord

  def queue(*args)
    Travis::Notifications::Worker::Queue.new(*args)
  end

  let(:common)  { queue('builds.common',  nil, nil, nil) }
  let(:rails)   { queue('builds.rails', 'rails/rails', nil) }
  let(:erlang)  { queue('builds.erlang', nil, 'erlang', nil) }
  let(:clojure) { queue('builds.common', nil, nil, 'clojure') }

  it "name still returns the actual class name for custom worker classes" do
    rails.name.should == 'builds.rails'
  end

  describe 'matches?' do
    it "returns true when the given slug matches" do
      rails.matches?('rails/rails', nil, nil).should be_true
    end

    # it "returns true when the given target matches" do
    #   erlang.matches?(nil, 'erlang', nil).should be_true
    # end

    it "returns true when the given language matches" do
      clojure.matches?(nil, nil, 'clojure').should be_true
    end

    it "returns false when none of slug, target or language match" do
      erlang.matches?('foo/bar', 'worker-on-mars', 'COBOL').should be_false
    end
  end

  describe "#jobs" do
    it "returns jobs that are matching the queue" do
      test = Factory.create(:test)
      ruby.jobs.should include(test)
    end
  end
end
