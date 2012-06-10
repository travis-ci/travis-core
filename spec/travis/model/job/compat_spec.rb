require 'spec_helper'

describe Job::Compat do
  include Support::ActiveRecord

  let(:test) { Factory(:test, :result => nil) }

  it 'writes status to result' do
    test.update_attributes(:status => 1)
    test.reload.result.should == 1
  end
end
