require 'spec_helper'
require 'support/active_record'

describe Travis::Notifications::SecureConfig do

  let(:key)            { SslKey.new.tap { |key| key.generate_keys } }
  let(:secure_config)  { Travis::Notifications::SecureConfig.new(key)}
  let(:crypted)        { Base64.encode64(key.encrypt('hello world')) }

  it "returns the original value if the config is not a hash" do
    secure_config.decrypt('hello world').should eql('hello world')
  end

  it "decrypts a string" do
    secure_config.decrypt(:secure => crypted).should eql('hello world')
  end

  it "decrypts an array with a secure entry and a string" do
    secure_config.decrypt([{ :secure => crypted }, "hola mundo"]).should eql(['hello world', 'hola mundo'])
  end

  it "decrypts a hash with a secure entry" do
    secure_config.decrypt({
      :english => { :secure => crypted },
      :spanish => 'hola mundo'
    }).should eql({
      :english => 'hello world',
      :spanish => 'hola mundo'
    })
  end

  it "decrypts a complex object of nested arrays and strings" do
    secure_config.decrypt({
      :a => [{ :secure => crypted }, 'hola mundo', 42],
      :b => "hello",
      :c => { :z => { :secure => crypted } }
    }).should eql({
      :a => ['hello world', 'hola mundo', 42],
      :b => "hello",
      :c => { :z => "hello world" }
    })
  end

  it "decrypts a realistic complex build config" do
    secure_config.decrypt({
      :script => "ruby -e \"p RUBY_VERSION\"; true && rake test",
      :rvm => ["1.8.7", "1.9.2", "1.9.3", "rbx", "jruby"],
      :matrix => {
        :exclude => [{ :rvm=>"rbx" }]
      },
      :branches => {
        :only=>"master"
      },
      :notifications => {
        :email => false,
        :campfire => {
          :secure => crypted
        }
      },
      :".configured" => true
    }).should eql({
      :script => "ruby -e \"p RUBY_VERSION\"; true && rake test",
      :rvm => ["1.8.7", "1.9.2", "1.9.3", "rbx", "jruby"],
      :matrix => {
        :exclude => [{ :rvm=>"rbx" }]
      },
      :branches => {
        :only=>"master"
      },
      :notifications => {
        :email => false,
        :campfire => "hello world"
      },
      :".configured" => true
    })
  end

  it "keeps the string similar if it couldn't be decoded" do
    secure_config.decrypt(:secure => "hello world").should eql("hello world")
  end
end
