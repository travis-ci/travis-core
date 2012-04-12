require 'spec_helper'
require 'support/active_record'

describe Request do
  include Support::ActiveRecord

  describe 'create' do
    let(:request) { Factory(:request).reload }

    it "creates the request's configure job" do
      request.job.should be_instance_of(Job::Configure)
    end
  end
end
