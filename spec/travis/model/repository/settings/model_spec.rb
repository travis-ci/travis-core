require 'spec_helper'

describe Repository::Settings::Model do
  attr_reader :model_class

  before do
    @model_class = Class.new(described_class) do
      field :name
      field :loves_travis, :boolean
      field :height, :integer

      field :secret, encrypted: true
    end
  end

  it 'does not coerce nil' do
    model = model_class.new(name: nil)
    model.name.should be_nil
  end

  it 'can be loaded from json' do
    key = 'foo' * 16
    encrypted = Travis::Model::EncryptedColumn.new(key: key, use_prefix: false).dump('foo')
    model = model_class.new({ secret: encrypted }, load: true, key: key)
    model.secret.decrypt.should == 'foo'
  end

  it 'allows to update attributes' do
    model = model_class.new
    model.update(name: 'Piotr', loves_travis: true, height: 178)
    model.name.should == 'Piotr'
    model.loves_travis.should be_true
    model.height.should == 178
  end

  it 'creates an instance with attributes' do
    model = model_class.new(name: 'Piotr', loves_travis: true, height: 178)
    model.name.should == 'Piotr'
    model.loves_travis.should be_true
    model.height.should == 178
  end

  it 'allows to overwrite values' do
    model = model_class.new(name: 'Piotr')
    model.name = 'Peter'
    model.name.should == 'Peter'
  end

  it 'coerces values by default' do
    model = model_class.new(height: '178', loves_travis: 'true')
    model.height.should == 178
    model.loves_travis.should == true
  end

  it 'allows to override attribute methods' do
    model_class.class_eval do
      def name
        super.upcase
      end
    end

    model = model_class.new(name: 'piotr')
    model.name.should == 'PIOTR'
  end

  it 'automatically generates id field' do
    field = model_class.field_by_name('id')
    field.should_not be_nil
    field.type.should == :uuid
  end

  it 'handles validations' do
    model_class = Class.new(described_class) do
      field :name

      validates :name, presence: true

      def self.name; "Foo"; end
    end

    model = model_class.new
    model.should_not be_valid
    model.errors[:name].should == [:blank]
  end

  describe 'encryption' do
    before do
      @model_class = Class.new(described_class) do
        field :secret, encrypted: true
      end
    end

    it 'automatically encrypts the data with passed key' do
      key = SecureRandom.hex(32)
      encrypted_column = Travis::Model::EncryptedColumn.new(use_prefix: false, key: key)
      model = model_class.new({ secret: 'foo' }, key: key)
      encrypted_column.load(model.secret).should == 'foo'
      model.secret.decrypt.should == 'foo'

      encrypted_column.load(model.to_hash['secret'].to_s).should == 'foo'
      encrypted_column.load(JSON.parse(model.to_json)['secret']).should == 'foo'
    end
  end
end
