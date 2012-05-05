require 'spec_helper'
require 'support/active_record'

describe Repository::Compat do
  include Support::ActiveRecord

  let(:repository) { Factory(:repository, :last_build_result => nil) }

  it 'writes status to result' do
    repository.update_attributes(:last_build_status => 1)
    repository.reload.last_build_result.should == 1
  end
end
