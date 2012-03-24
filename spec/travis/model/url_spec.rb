require 'spec_helper'
require 'support/active_record'

describe Url do
  include Support::ActiveRecord


  it "should set the code automatically" do
    url = described_class.create :url => "http://example.com"
    url.code.should_not be_nil
  end
end
