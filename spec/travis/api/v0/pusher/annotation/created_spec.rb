require 'spec_helper'

describe Travis::Api::V0::Pusher::Annotation::Created do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { described_class.new(annotation).data }

  it 'annotation' do
    data['annotation'].should == {
      'id' => annotation.id,
      'job_id' => annotation.job_id,
      'description' => annotation.description,
      'url' => annotation.url,
      'provider_name' => 'Travis CI',
      'status' => '',
    }
  end
end
