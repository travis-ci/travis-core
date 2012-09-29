require 'spec_helper'

module Test
  module Services
    module Foo
      class Base; def initialize(*); end; end
      class All < Base; end
      class ByIds < Base; end
      class One < Base; end
      class OneOrCreate < Base; end
      class Update < Base; end
      class Stuff < Base; end
    end
  end

  class Foo
    include Travis::Services
  end
end

describe Travis::Services do
  let(:object) { Test::Foo.new }

  before :each do
    Travis::Services.namespace = 'Test::Services'
  end

  describe 'all' do
    it 'returns an instance of All if params are empty' do
      object.all({}).should be_instance_of(Test::Services::Foo::All)
    end

    it 'returns an instance of ByIds if params have the key :ids' do
      object.all(:ids => [1]).should be_instance_of(Test::Services::Foo::ByIds)
    end
  end

  describe 'one' do
    it 'returns an instance of One if params have the key :id' do
      object.one(:id => 1).should be_instance_of(Test::Services::Foo::One)
    end
  end

  describe 'update' do
    it 'returns an instance of update' do
      object.update({}).should be_instance_of(Test::Services::Foo::Update)
    end
  end

  describe 'service' do
    it 'given a Foo as a namespace and Stuff as a name it returns an instance of Foo::Stuff' do
      object.service(:foo, :stuff, {}).should be_instance_of(Test::Services::Foo::Stuff)
    end

    it 'given no namespace and Stuff as a name it infers the namespace and returns an instance of Foo::Stuff' do
      object.service(:stuff, {}).should be_instance_of(Test::Services::Foo::Stuff)
    end
  end
end
