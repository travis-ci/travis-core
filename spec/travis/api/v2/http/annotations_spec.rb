require 'spec_helper'

describe Travis::Api::V2::Http::Annotations do
  include Travis::Testing::Stubs, Support::Formats

  let(:data) { described_class.new([annotation]).data }

  it "annotations" do
    data["annotations"].should eq([{
      'id' => annotation.id,
      'job_id' => test.id,
      'description' => annotation.description,
      'url' => annotation.url,
      'image' => nil,
      'provider_name' => 'Travis CI',
    }])
  end

  describe 'annotations.image' do
    it 'with an image' do
      annotation.stubs(image_url: 'https://example.com/image.png', image_alt: 'Some image')
      data['annotations'].first['image'].should eq({
        'url' => annotation.image_url,
        'alt' => annotation.image_alt,
      })
    end

    it 'without an image' do
      data['annotations'].first['image'].should be_nil
    end
  end
end
