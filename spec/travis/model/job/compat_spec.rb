require 'spec_helper'
require 'support/active_record'

describe Job::Compat do
  include Support::ActiveRecord

  let(:configure) { Factory(:configure) }
  let(:test)      { Factory(:test) }

  describe 'copy_status_to_result' do
    it 'copies result to status (configure job)' do
      configure.update_attributes(:status => 1)
      configure.reload.result.should == 1
    end

    it 'copies result to status (test job)' do
      test.update_attributes(:status => 1)
      test.reload.result.should == 1
    end
  end
end
