require 'spec_helper'

describe Travis::Services::UpdateArtifact do
  include Travis::Testing::Stubs

  let(:service) { described_class.new(user, params) }
  let(:params)  { { id: log.id, archived_at: Time.now } }

  before :each do
    log.stubs(:update_attributes).returns(true)
    service.stubs(:run_service).with(:find_artifact, id: log.id).returns(log)
  end

  it 'updates the artifact' do
    log.expects(:update_attributes).with(archived_at: params[:archived_at])
    service.run
  end


  describe 'the instrument' do
    let(:publisher) { Travis::Notification::Publisher::Memory.new }
    let(:event)     { publisher.events.last }

    before :each do
      Travis::Notification.publishers.replace([publisher])
    end

    it 'publishes a event' do
      service.run
      event.should publish_instrumentation_event(
        event: 'travis.services.update_artifact.run:completed',
        message: "Travis::Services::UpdateArtifact#run:completed for #<Artifact id=#{log.id}> params=#{params}",
        result: true
      )
    end
  end
end
