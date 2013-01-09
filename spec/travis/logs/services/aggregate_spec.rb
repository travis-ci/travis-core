require 'spec_helper'

describe Travis::Logs::Services::Aggregate do
  include Support::ActiveRecord

  let(:service) { described_class.new }
  let(:log)     { Factory(:log, content: nil) }
  let(:lines)   { ["line 1\n", "line 2\n", 'Done. Build script exited with: 0'] }

  let(:interval_regular) { Travis.config.logs.intervals.regular + 10 }
  let(:interval_force)   { Travis.config.logs.intervals.force + 10 }

  def create_parts(id, interval, final)
    lines.each_with_index do |content, ix|
      Artifact::Part.create!(artifact_id: id, content: content, number: ix, final: final && ix == lines.count - 1)
      Artifact::Part.update_all(created_at: interval.seconds.ago)
    end
  end

  before :each do
    Travis::Features.start
    Travis::Features.stubs(:feature_active?).with(:log_aggregation).returns(true)
  end

  it 'aggregates parts where no parts have been added for [regular interval] seconds and the final flag is set' do
    create_parts(log.id, interval_regular, true)
    Artifact::Log.expects(:aggregate).with(log.id)
    service.run
  end

  it 'does not aggregates parts where no parts have been added for [regular interval] seconds and the final flag is not set' do
    create_parts(log.id, interval_regular, false)
    Artifact::Log.expects(:aggregate).never
    service.run
  end

  it 'aggregates parts where no parts have been added for [force interval] seconds' do
    create_parts(log.id, interval_force, false)
    Artifact::Log.expects(:aggregate).with(log.id)
    service.run
  end

  it 'aggregates parts to log.content (integrate db)' do
    create_parts(log.id, interval_regular, true)
    -> { service.run }.should change(Artifact::Part, :count).by(-3)
    log.reload.content.should == lines.join
  end
end

