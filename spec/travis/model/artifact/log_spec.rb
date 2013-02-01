require 'spec_helper'

describe Artifact::Log do
  include Support::ActiveRecord

  let!(:log)  { job.log }
  let(:job)   { Factory.create(:test, log: Factory.create(:log, content: '')) }
  let(:lines) { ["line 1\n", "line 2\n", 'line 3'] }

  describe 'class methods' do
    it 'is archived only when archive is verified' do
      log.archived_at = Time.now
      log.should_not be_archived
      log.archive_verified = true
      log.should be_archived
    end

    describe '#to_json' do
      it 'returns JSON representation of the record' do
        json = JSON.parse(job.log.to_json)
        json['log']['id'].should == job.log.id
      end
    end
  end

  describe 'content' do
    it 'while not aggregated it returns the aggregated parts' do
      lines.each_with_index { |line, ix| Artifact::Part.create!(artifact_id: log.id, content: line, number: ix) }
      log.content.should == lines.join
    end

    it 'while not aggregated it appends to an existing log' do
      job.log.update_attributes(content: 'foo')
      Artifact::Part.create!(artifact_id: log.id, content: 'bar')
      log.content.should == 'foobar'
    end

    it 'if aggregated returns the aggregated parts' do
      log.update_attributes!(content: 'content', aggregated_at: Time.now)
      log.content.should == 'content'
    end
  end

  describe '#clear!' do
    it 'clears log parts' do
      Artifact::Part.create!(artifact_id: log.id, content: 'bar')
      -> { log.clear! }.should change { log.parts.length }.by(-1)
    end

    it 'resets content' do
      log.update_attributes!(content: 'foo')
      log.clear!
      log.reload.content.should == ''
    end

    it 'resets aggregated_at' do
      log.update_attributes!(aggregated_at: Time.now)
      log.clear!
      log.reload.aggregated_at.should be_nil
    end

    it 'resets archived_at' do
      log.update_attributes!(archived_at: Time.now)
      log.clear!
      log.reload.archived_at.should be_nil
    end

    it 'resets archive_verified' do
      log.update_attributes!(archive_verified: true)
      log.clear!
      log.reload.archive_verified.should be_nil
    end
  end
end

