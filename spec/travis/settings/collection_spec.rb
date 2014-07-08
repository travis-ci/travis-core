require 'spec_helper'

describe Travis::Settings::Collection do
  attr_reader :collection_class

  before do
    @model_class = Class.new(Travis::Settings::Model) {
      attribute :description

      attribute :id, String
      attribute :secret, Travis::Settings::EncryptedValue
    }

    Travis::Settings.const_set('Foo', @model_class)
    @collection_class = Class.new(described_class) do
      model Travis::Settings::Foo
    end
  end

  after do
    Travis::Settings.send(:remove_const, 'Foo')
  end

  it 'loads models from JSON' do
    encrypted = Travis::Model::EncryptedColumn.new(use_prefix: false).dump('foo')
    json = [{ id: 'ID', description: 'a record', secret: encrypted }]
    collection = collection_class.new
    collection.load(json)
    record = collection.first
    record.id.should == 'ID'
    record.description.should == 'a record'
    record.secret.decrypt.should == 'foo'
  end

  it 'finds class in Travis::Settings namespace' do
    collection_class.model.should == Travis::Settings::Foo
  end

  it 'allows to create a model' do
    SecureRandom.expects(:uuid).returns('uuid')
    collection = collection_class.new
    model = collection.create(description: 'foo')
    model.description.should == 'foo'
    collection.to_a.should == [model]
    model.id.should == 'uuid'
  end

  describe '#destroy' do
    it 'removes an item from collection' do
      collection = collection_class.new
      item = collection.create(description: 'foo')

      collection.should have(1).item

      collection.destroy(item.id)

      collection.should have(0).items
    end
  end

  describe '#find' do
    it 'finds an item' do
      collection = collection_class.new
      item = collection.create(description: 'foo')

      collection.should have(1).item

      collection.find(item.id).should == item
      collection.find('foobarbaz').should be_nil
    end
  end
end
