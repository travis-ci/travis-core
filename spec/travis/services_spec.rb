require 'spec_helper'

module Test
  module Services
    module Foo
      class Stuff < Struct.new(:current_user, :params); end
    end
  end

  class Foo
    include Travis::Services
  end
end

describe Travis::Services do
  include Travis::Testing::Stubs

  let(:object) { Test::Foo.new }

  before :each do
    Travis.stubs(:services).returns(Test::Services)
  end

  describe 'service' do
    it 'given :foo as a type and :stuff as a name it returns an instance of Foo::Stuff' do
      object.service(:foo, :stuff, {}).should be_instance_of(Test::Services::Foo::Stuff)
    end

    it 'passes the given user' do
      object.service(:foo, :stuff, user).current_user.should == user
    end

    it 'passes the given params' do
      params = { :some => :thing }
      object.service(:foo, :stuff, params).params.should == params
    end

    it 'defaults params to {}' do
      object.service(:foo, :stuff).params.should == {}
    end

    it 'defaults the user to the current user if the object responds to :current_user' do
      object.stubs(:current_user).returns(user)
      object.service(:foo, :stuff, {}).current_user.should == user
    end

    it 'defaults the user to nil if the object does not respond to :current_user' do
      object.service(:foo, :stuff, {}).current_user.should be_nil
    end
  end
end
