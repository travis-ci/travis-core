require 'spec_helper'

describe Travis::UrlShortener do
  describe "create" do
    it "should return the Bitly shortener" do
      subject.create.should be_a Travis::UrlShortener::Bitly
    end
  end
end