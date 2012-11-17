require 'spec_helper'

describe Travis::Github::Services::FindOrCreateRepo do
  include Travis::Testing::Stubs

  let(:service) { described_class.new(nil, {}) }

  before :each do
  end

  xit 'needs to be specified' do
  end
end
