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
    Travis.services = Test::Services
  end

  after :each do
    Travis.services = Travis::Services
  end

  describe 'service' do
    it 'given a :foo as a type and :stuff as a name it returns an instance of Foo::Stuff' do
      object.service(:foo, :stuff, {}).should be_instance_of(Test::Services::Foo::Stuff)
    end
  end
end
