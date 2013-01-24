require 'spec_helper'

describe Artifact::Log do
  include Support::ActiveRecord

  describe 'class methods' do
    let!(:log)  { job.log }
    let(:job)   { Factory.create(:test, log: Factory.create(:log, content: '')) }
    let(:lines) { ["line 1\n", "line 2\n", 'line 3'] }

    before :each do
      Travis::Features.start
      Travis::Features.disable_for_all(:log_aggregation)
    end

    describe '#to_json' do
      it 'returns JSON representation of the record' do
        json = JSON.parse(job.log.to_json)
        json['log']['id'].should == job.log.id
      end
    end

    describe 'given no part number' do
      describe 'append' do
        it 'appends streamed build log chunks' do
          0.upto(2) { |ix| Artifact::Log.append(job.id, lines[ix]) }
          job.log.reload.content.should == lines.join
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

    describe 'given a part number and :log_aggregation being activated' do
      before :each do
        Travis::Features.enable_for_all(:log_aggregation)
      end

      describe 'append' do
        it 'creates a log part with the given number' do
          Artifact::Log.append(job.id, lines.first, 1)
          log.parts.first.content.should == lines.first
        end

        it 'filters out null chars' do
          Artifact::Log.append(job.id, "a\0b\0c", 1)
          log.parts.first.content.should == 'abc'
        end

        it 'filters out triple null chars' do
          Artifact::Log.append(job.id, "a\000b\000c", 1)
          log.parts.first.content.should == 'abc'
        end

        it 'does not set the :final flag if the appended message does not contain the final log message part' do
          Artifact::Log.append(job.id, lines.first, 1)
          log.parts.first.final.should be_false
        end

        it 'sets the :final flag if the appended message contains the final log message part' do
          Artifact::Log.append(job.id, "some log.\n#{Artifact::Log::FINAL} result", 1)
          log.parts.first.final.should be_true
        end
      end

      describe 'content' do
        it 'while not aggregated it returns the aggregated parts' do
          lines.each_with_index { |line, ix| Artifact::Log.append(job.id, line, ix) }
          log.content.should == lines.join
        end

        it 'while not aggregated it appends to an existing log' do
          job.log.update_attributes(content: 'foo')
          Artifact::Log.append(job.id, 'bar')
          log.content.should == 'foobar'
        end

        it 'if aggregated returns the aggregated parts' do
          log.update_attributes!(content: 'content', aggregated_at: Time.now)
          log.content.should == 'content'
        end
      end

      describe '#clear!' do
        it 'clears log parts' do
          Artifact::Log.append(job.id, 'bar')

          log.parts.length.should == 1

          expect {
            log.clear!
          }.to change { log.parts.length }.by(-1)
        end
      end

      describe 'aggregate' do
        before :each do
          lines.each_with_index { |line, ix| Artifact::Log.append(job.id, line, ix) }
          # Artifact::Log.append(job.id + 1, 'foo', 1)
        end

        def aggregate!
          Artifact::Log.aggregate(log.id)
          log.reload
        rescue ActiveRecord::ActiveRecordError => e
        end

        it 'aggregates the content parts' do
          aggregate!
          log.content.should == lines.join
        end

        it 'appends to an existing log' do
          log.update_attributes(content: 'foo')
          aggregate!
          log.content.should == 'foo' + lines.join
        end

        it 'sets aggregated_at' do
          aggregate!
          log.aggregated_at.to_s.should == Time.now.to_s
        end

        it 'deletes the content parts from the parts table' do
          aggregate!
          log.parts.should be_empty
        end

        it 'triggers a log:aggregated event' do
          Travis::Event.expects(:dispatch).with('log:aggregated', log)
          aggregate!
        end

        shared_examples_for :rolled_back_log_aggregation do
          it 'does not set aggregated_at' do
            aggregate!
            log.aggregated_at.should be_nil
          end

          it 'does not set the content' do
            aggregate!
            log.read_attribute(:content).should be_nil
          end

          it 'does not delete parts' do
            -> { aggregate! }.should_not change(Artifact::Part, :count)
          end
        end

        describe 'rolls back if log aggregation fails' do
          before :each do
            Artifact::Part.stubs(:aggregate).raises(ActiveRecord::ActiveRecordError)
          end

          it_behaves_like :rolled_back_log_aggregation
        end

        describe 'rolls back if parts deletion fails' do
          before :each do
            Artifact::Part.stubs(:delete_all).raises(ActiveRecord::ActiveRecordError)
          end

          it_behaves_like :rolled_back_log_aggregation
        end
      end
    end
  end
end

