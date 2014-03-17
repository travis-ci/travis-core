require 'spec_helper'

describe Repository::Settings::Collection do
  before do
    Repository::Settings.const_set('Foo', Class.new)
    @collection_class = Class.new(described_class) do
      model :foo
    end
  end

  after do
    Repository::Settings.send(:remove_const, 'Foo')
  end

  it 'finds class in Repository::Settings namespace' do
    @collection_class.model.should == Repository::Settings::Foo
  end
end
