require 'spec_helper'

describe Job::Compat do
  include Support::ActiveRecord

  let(:configure) { Factory(:configure, :result => nil) }
  let(:test)      { Factory(:test, :result => nil) }

  it 'writes status to result (configure job)' do
    configure.update_attributes(:status => 1)
    configure.reload.result.should == 1
  end

  it 'writes status to result (test job)' do
    test.update_attributes(:status => 1)
    test.reload.result.should == 1
  end
end
