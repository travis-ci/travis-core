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

  describe "encrypt" do
    it "should encrypt something" do
      ssl_key.encrypt("hello").should_not be_nil
      ssl_key.encrypt("hello").should_not eql("hello")
    end

    it "should be decryptable" do
      encrypted = ssl_key.encrypt("hello")
      ssl_key.decrypt(encrypted).should eql("hello")
    end
  end

  describe "decrypt" do
    it "should decrypt something" do
      encrypted_string = ssl_key.encrypt("hello world")
      ssl_key.decrypt(encrypted_string).should_not be_nil
      ssl_key.decrypt(encrypted_string).should_not eql("hello")
    end
  end
end
