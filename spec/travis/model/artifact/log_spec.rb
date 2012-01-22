require 'spec_helper'
require 'support/active_record'

describe Artifact::Log do
  include Support::ActiveRecord

  describe 'class methods' do
    let(:job)   { Factory.create(:test, :log => Factory.create(:log, :content => '')) }
    let(:lines) { ["line 1\n", "line 2\n", "line 3"] }

    describe ".prepend" do
      it "appends streamed build log chunks" do
        0.upto(2) { |ix| Artifact::Log.prepend(job.id, lines[ix]) }
        job.reload.log.content.should == lines.reverse.join
      end
    end

    describe ".append" do
      it "appends streamed build log chunks" do
        0.upto(2) { |ix| Artifact::Log.append(job.id, lines[ix]) }
        job.reload.log.content.should == lines.join
      end
    end
  end

  describe 'instance methods' do
    describe 'prepend' do
      it 'prepends the given chars to an unpersisted record' do
        log = Factory.build(:log, :content => 'bar')
        log.prepend('foo')
        log.content.should == 'foobar'
      end

      it 'prepends the given chars to a persisted record' do
        log = Factory.create(:log, :content => 'bar')
        Artifact::Log.expects(:prepend).with(log.id, 'foo')
        log.prepend('foo')
      end
    end
  end
end

