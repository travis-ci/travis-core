require 'spec_helper'

describe Travis::Settings::Model do
  attr_reader :model_class

  before do
    @model_class = Class.new(described_class) do
      attribute :name
      attribute :loves_travis, :Boolean
      attribute :height, Integer
      attribute :awesome, :Boolean, default: true

      attribute :secret, Travis::Settings::EncryptedValue
    end
  end

  it 'returns a default if it is set' do
    model_class.new.awesome.should be_true
  end

  it 'allows to override the default' do
    model_class.new(awesome: false).awesome.should be_false
  end

  it 'validates encrypted attributes properly' do
    model_class = Class.new(described_class) do
      attribute :secret, Travis::Settings::EncryptedValue
      validates :secret, presence: true
    end

    model = model_class.new
    model.should_not be_valid
    model.errors[:secret].should == [:blank]
  end

  it 'implements read_attribute_for_serialization method' do
    model = model_class.new(name: 'foo')
    model.read_attribute_for_serialization(:name).should == 'foo'
  end

  it 'does not coerce nil' do
    model = model_class.new(name: nil)
    model.name.should be_nil
  end

  it 'can be loaded from json' do
    encrypted = Travis::Model::EncryptedColumn.new(use_prefix: false).dump('foo')
    model = model_class.load(secret: encrypted)
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

  it 'handles validations' do
    model_class = Class.new(described_class) do
      attribute :name

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
        attribute :secret, Travis::Settings::EncryptedValue
      end
    end

    it 'returns EncryptedValue instance even for nil values' do
      model_class.new.secret.should be_a Travis::Settings::EncryptedValue
    end

    it 'automatically encrypts the data' do
      encrypted_column = Travis::Model::EncryptedColumn.new(use_prefix: false)
      model = model_class.new secret: 'foo'
      encrypted_column.load(model.secret).should == 'foo'
      model.secret.decrypt.should == 'foo'

      encrypted_column.load(model.to_hash[:secret].to_s).should == 'foo'
      encrypted_column.load(JSON.parse(model.to_json)['secret']).should == 'foo'
    end
  end
end
