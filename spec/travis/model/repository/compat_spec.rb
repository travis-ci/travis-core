require 'spec_helper'
require 'support/active_record'

describe Repository::Compat do
  include Support::ActiveRecord

  let(:repository) { Factory(:repository) }

  describe 'copy_status_to_result' do
    it 'copies result to status' do
      repository.update_attributes(:last_build_status => 1)
      repository.reload.last_build_result.should == 1
    end
  end
end
