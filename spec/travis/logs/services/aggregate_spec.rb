require 'spec_helper'

describe Travis::Logs::Services::Aggregate do
  include Support::ActiveRecord

  let!(:log)    { job.log }
  let(:job)     { Factory.create(:test, log: Factory.create(:log, content: '')) }
  let(:lines)   { ["line 1\n", "line 2\n", 'Done. Build script exited with: 0'] }
  let(:service) { described_class.new }

  let(:interval_regular) { Travis.config.logs.intervals.regular + 10 }
  let(:interval_force)   { Travis.config.logs.intervals.force + 10 }

  def create_parts(id, interval, final)
    lines.each_with_index do |content, ix|
      Artifact::Part.create!(log_id: id, content: content, number: ix, final: final && ix == lines.count - 1)
      Artifact::Part.update_all(created_at: interval.seconds.ago)
    end
  end

  before :each do
    Travis::Features.stubs(:feature_active?).with(:log_aggregation).returns(true)
  end

  it 'aggregates logs where no parts have been added for [regular interval] seconds and the final flag is set' do
    create_parts(log.id, interval_regular, true)
    service.expects(:aggregate).with(log.id.to_s)
    service.run
  end

  it 'does not aggregates logs where no parts have been added for [regular interval] seconds and the final flag is not set' do
    create_parts(log.id, interval_regular, false)
    service.expects(:aggregate).never
    service.run
  end

  it 'aggregates logs where no parts have been added for [force interval] seconds' do
    create_parts(log.id, interval_force, false)
    service.expects(:aggregate).with(log.id.to_s)
    service.run
  end

  it 'aggregates parts to log.content' do
    create_parts(log.id, interval_regular, true)
    -> { service.run }.should change(Artifact::Part, :count).by(-3)
    log.reload.content.should == lines.join
  end

  describe 'aggregate' do
    before :each do
      create_parts(log.id, interval_regular, true)
    end

    it 'aggregates the content parts' do
      service.run
      log.reload.content.should == lines.join
    end

    it 'appends to an existing log' do
      log.update_attributes(content: 'foo')
      service.run
      log.reload.content.should == 'foo' + lines.join
    end

    it 'sets aggregated_at' do
      service.run
      log.reload.aggregated_at.to_s.should == Time.now.to_s
    end

    it 'deletes the content parts from the parts table' do
      service.run
      log.reload.parts.should be_empty
    end

    it 'triggers a log:aggregated event' do
      Travis::Event.expects(:dispatch).with('log:aggregated', log)
      service.run
    end
  end

  describe 'rollback' do
    before :each do
      # lines.each_with_index { |line, ix| Artifact::Part.create!(log_id: log.id, content: line, number: ix) }
      create_parts(log.id, interval_regular, true)
    end

    shared_examples_for :rolled_back_log_aggregation do
      it 'does not set aggregated_at' do
        service.run
        log.reload.aggregated_at.should be_nil
      end

      it 'does not set the content' do
        service.run
        log.reload.read_attribute(:content).should be_nil
      end

      it 'does not delete parts' do
        -> { service.run }.should_not change(Artifact::Part, :count)
      end

      it 'handles the exception' do
        Travis::Exceptions.expects(:handle).with { |e| e.is_a?(ActiveRecord::ActiveRecordError) }
        service.run
      end
    end

    describe 'rolls back if log aggregation fails' do
      before :each do
        service.stubs(:aggregate).raises(ActiveRecord::ActiveRecordError)
      end

      it_behaves_like :rolled_back_log_aggregation
    end

    describe 'rolls back if parts deletion fails' do
      before :each do
        Artifact::Part.expects(:delete_all).raises(ActiveRecord::ActiveRecordError)
      end

      it_behaves_like :rolled_back_log_aggregation
    end
  end
end
