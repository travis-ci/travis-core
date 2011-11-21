require 'spec_helper'
require 'core_ext/module/prepend_to'

describe Module, 'extensions' do
  describe 'prepend_to' do
    it 'works with a method defined on a class' do
      klass = Class.new { def foo; :foo; end }
      klass.prepend_to(:foo) { [super(), :bar] }
      klass.new.foo.should == [:foo, :bar]
    end

    it 'works with a method defined on a module' do
      modul = Module.new { def foo; :foo; end }
      klass = Class.new { include modul }
      klass.prepend_to(:foo) { [super(), :bar] }
      klass.new.foo.should == [:foo, :bar]
    end
  end
end
