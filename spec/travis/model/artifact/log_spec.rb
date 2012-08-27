require 'spec_helper'

describe Artifact::Log do
  include Support::ActiveRecord

  describe 'class methods' do
    let(:job)   { Factory.create(:test, :log => Factory.create(:log, :content => '')) }
    let(:lines) { ["line 1\n", "line 2\n", 'line 3'] }

    describe 'append' do
      it 'appends streamed build log chunks' do
        0.upto(2) { |ix| Artifact::Log.append(job.id, lines[ix]) }
        job.reload.log.content.should == lines.join
      end

      it 'filters out null chars' do
        Artifact::Log.expects(:update_all).with do |updates, *args|
          updates.last.should == 'abc'
        end
        Artifact::Log.append(job.id, "a\0b\0c")
      end

      it 'filters out triple null chars' do
        Artifact::Log.expects(:update_all).with do |updates, *args|
          updates.last.should == 'abc'
        end
        Artifact::Log.append(job.id, "a\000b\000c")
      end
    end
  end
end

