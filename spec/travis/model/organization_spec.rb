require 'spec_helper'

describe User do
  include Support::ActiveRecord

    let(:org)    { Factory.create(:org, :login => 'travis-organization') }
    let(:org2)         { Factory.create(:org, :login => 'travis-ci') }

    describe 'educational_org' do
      it 'returns true if organization is flagged as educational_org' do
        Travis::Features.activate_owner(:educational_org, org)
        Travis::Features.owner_active?(:educational_org, org).should be_true
      end

      it 'returns false if the organization has not been flagged as educational_org' do
        Travis::Features.activate_owner(:educational_org, org)
        Travis::Features.owner_active?(:educational_org, org2).should be_false
      end
    end
end