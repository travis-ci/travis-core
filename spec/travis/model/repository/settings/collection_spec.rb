require 'spec_helper'

describe Repository::Settings::Collection do
  before do
    @model_class = Class.new(Repository::Settings::Model) {
      field :description

      field :secret, encrypted: true
    }

    Repository::Settings.const_set('Foo', @model_class)
    @collection_class = Class.new(described_class) do
      model :foo
    end
  end

  after do
    Repository::Settings.send(:remove_const, 'Foo')
  end

  it 'loads models from JSON' do
    encrypted = Travis::Model::EncryptedColumn.new(use_prefix: false).dump('foo')
    json = [{ id: 'ID', description: 'a record', secret: encrypted }]
    collection = @collection_class.new
    collection.load(json)
    record = collection.first
    record.id.should == 'ID'
    record.description.should == 'a record'
    record.secret.decrypt.should == 'foo'
  end

  it 'finds class in Repository::Settings namespace' do
    @collection_class.model.should == Repository::Settings::Foo
  end

  it 'allows to create a model' do
    SecureRandom.expects(:uuid).returns('uuid')
    collection = @collection_class.new
    model = collection.create(description: 'foo')
    model.description.should == 'foo'
    collection.to_a.should == [model]
    model.id.should == 'uuid'
  end
end
