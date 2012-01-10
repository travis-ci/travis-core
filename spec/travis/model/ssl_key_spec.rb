require 'spec_helper'

describe SslKey do
  include Support::ActiveRecord

  let(:ssl_key) { SslKey.new }

  before(:each) { ssl_key.generate_keys }

  it "is a SslKey" do
    ssl_key.should be_a(SslKey)
  end

  describe "generate_keys" do
    it "generates the public key" do
      ssl_key.public_key.should be_a(String)
    end

    it "generates the private key" do
      ssl_key.private_key.should be_a(String)
    end

    it "does not generate a new public key if one already exists" do
      public_key = ssl_key.public_key
      ssl_key.generate_keys
      ssl_key.public_key.should == public_key
    end

    it "does not generate a new private key if one already exists" do
      private_key = ssl_key.private_key
      ssl_key.generate_keys
      ssl_key.private_key.should == private_key
    end
  end

  describe "generate_keys!" do
    it "generates a new public key even if one already exists" do
      public_key = ssl_key.public_key
      ssl_key.generate_keys!
      ssl_key.public_key.should_not == public_key
    end

    it "generates a new private key even if one already exists" do
      private_key = ssl_key.private_key
      ssl_key.generate_keys!
      ssl_key.private_key.should_not == private_key
    end
  end

  describe "encrypt" do
    it "encrypts something" do
      ssl_key.encrypt("hello").should_not be_nil
      ssl_key.encrypt("hello").should_not eql("hello")
    end

    it "is decryptable" do
      encrypted = ssl_key.encrypt("hello")
      ssl_key.decrypt(encrypted).should eql("hello")
    end
  end

  describe "decrypt" do
    it "decrypts something" do
      encrypted_string = ssl_key.encrypt("hello world")
      ssl_key.decrypt(encrypted_string).should_not be_nil
      ssl_key.decrypt(encrypted_string).should_not eql("hello")
    end
  end
end
