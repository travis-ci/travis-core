require 'spec_helper'

describe Travis::Services::UpdateAnnotation do
  include Support::ActiveRecord

  let(:annotation_provider) { Factory(:annotation_provider) }
  let(:job) { Factory(:test) }
  let(:service) { described_class.new(params) }

  attr_reader :params

  it 'creates the annotation if it doesn\'t exist already' do
    @params = {
      username: annotation_provider.api_username,
      key: annotation_provider.api_key,
      job_id: job.id,
      description: 'Foo bar baz',
    }

    annotation = service.run
    annotation.description.should eq(params[:description])
  end

  it 'updates an existing annotation if one exists' do
    @params = {
      username: annotation_provider.api_username,
      key: annotation_provider.api_key,
      job_id: job.id,
      description: 'Foo bar baz',
    }

    annotation = Factory(:annotation, annotation_provider: annotation_provider, job: job)
    service.run.id.should eq(annotation.id)
  end

  it 'returns nil when given invalid provider credentials' do
    @params = {
      username: 'some-invalid-provider',
      key: 'some-invalid-key',
      job_id: job.id,
      description: 'Foo bar baz',
    }

    service.run.should be_nil
  end
end
