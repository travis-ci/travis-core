require 'spec_helper'

describe Build::Compat do
  include Support::ActiveRecord

  let(:build) { Factory(:build, result: nil) }

  it 'writes status to result' do
    build.update_attributes(status: 1)
    build.reload.result.should == 1
  end
end
