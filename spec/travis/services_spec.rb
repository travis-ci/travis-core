require 'spec_helper'

module Test
  module Services
    module Foo
      # class Stuff; def initialize(*); end; end
      class Stuff < Struct.new(:current_user, :params); end
    end
  end

  class Foo
    include Travis::Services
    def current_user; :user; end
  end
end

describe Travis::Services do
  let(:object) { Test::Foo.new }

  before :each do
    Travis.services = Test::Services
  end

  after :each do
    Travis.services = Travis::Services
  end

  describe 'service' do
    it 'given a :foo as a type and :stuff as a name it returns an instance of Foo::Stuff' do
      object.service(:foo, :stuff, {}).should be_instance_of(Test::Services::Foo::Stuff)
    end

    it 'it passes the current user' do
      object.service(:foo, :stuff, {}).current_user.should == :user
    end

    it 'it passes the given params' do
      params = { :some => :thing }
      object.service(:foo, :stuff, params).params.should == params
    end
  end
end
