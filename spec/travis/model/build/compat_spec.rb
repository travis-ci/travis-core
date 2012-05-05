require 'spec_helper'
require 'support/active_record'

describe Build::Compat do
  include Support::ActiveRecord

  let(:build) { Factory(:build) }

  describe 'copy_status_to_result' do
    it 'copies result to status' do
      build.update_attributes(:status => 1)
      build.reload.result.should == 1
    end
  end
end
