require 'spec_helper'

describe SslKey do
  include Support::ActiveRecord
  let(:repository) { Factory(:repository) }
  let(:ssl_key) { repository.key }

  it "should be a SslKey" do
    ssl_key.should be_a(SslKey)
  end

  describe "generate keys" do

    it "should generate the public key" do
      ssl_key.reload.public_key.should_not be_nil
    end

    it "should generate the private key" do
      ssl_key.reload.private_key.should_not be_nil
    end
  end
end
