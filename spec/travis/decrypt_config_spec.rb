require 'spec_helper'
require 'support/active_record'

describe Travis::DecryptConfig do
  include Support::ActiveRecord
  let(:repository) { Factory(:repository) }
  let(:object) { Travis::DecryptConfig.new(repository)}

  before do
    @crypted = repository.key.encrypt('hello world')
    repository.key.decrypt(@crypted).should eql('hello world')
  end

  it "should decrypt a string" do
    object.run("secure:#{@crypted}").should eql('hello world')
  end

  it "should decrypt an array of strings" do
    object.run(["secure:#{@crypted}", "hola mundo"]).should eql(['hello world', 'hola mundo'])
  end

  it "should decrypt a hash of strings" do
    object.run({
      :english => "secure:#{@crypted}",
      :spanish => 'hola mundo'
    }).should eql({
      :english => 'hello world',
      :spanish => 'hola mundo'
    })
  end

  it "should decrypt a complex object of nested arrays and strings" do
    object.run({
      :a => ["secure:#{@crypted}", 'hola mundo', 42],
      :b => "hello",
      :c => {:z => "secure:#{@crypted}"}
    }).should eql({
      :a => ['hello world', 'hola mundo', 42],
      :b => "hello",
      :c => {:z => "hello world"}
    })
  end

  it "should keep the string similar if it couldn't be decoded" do
    object.run("secure:hello world").should eql("secure:hello world")
  end
end
