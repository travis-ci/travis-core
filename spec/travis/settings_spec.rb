require 'spec_helper'

describe Travis::Settings do
  it 'returns validations without going through i18n' do
    settings = Class.new(Travis::Settings) {
      attribute :foo, String
      validates :foo, presence: true
    }.new

    settings.foo = nil
    settings.should_not be_valid
    settings.errors[:foo].should == [:blank]
  end

  describe 'adding a setting' do
    let(:settings_class) {
      Class.new(Travis::Settings) {
        attribute :an_integer_field, Integer
        attribute :a_boolean_field, :Boolean, default: true
      }
    }

    it 'doesn\'t allow to set or get unknown settings' do
      settings = settings_class.new
      settings.merge('foo' => 'bar')

      settings.to_hash['foo'].should be_nil
    end

    it 'sets false properly as boolean, not changing it to nil' do
       settings = settings_class.new

      settings.a_boolean_field?.should be_true

      settings.a_boolean_field = false
      settings.a_boolean_field?.should == false
    end

    it 'allows to set a property using accessor' do
      settings = settings_class.new

      settings.an_integer_field.should be_nil

      settings.an_integer_field = 1
      settings.an_integer_field.should == 1
    end
  end

  describe 'simple_attributes' do
    it 'returns only plan attributes' do
      model_class = Class.new(Travis::Settings::Model) {
        attribute :name, String
      }
      collection_class = Class.new(Travis::Settings::Collection) {
        model model_class
      }
      settings_class = Class.new(Travis::Settings) {
        attribute :items, collection_class
        attribute :item, model_class
        attribute :secret, Travis::Settings::EncryptedValue
        attribute :plain, String
      }

      settings = settings_class.new

      settings.load({ items: [{ name: 'foo'}],
                      item: { name: 'bar' },
                      secret: Travis::Settings::EncryptedValue.new('baz'),
                      plain: 'yup' })

      settings.items.first.name.should == 'foo'
      settings.item.name.should == 'bar'
      settings.secret.decrypt.should == 'baz'

      settings.simple_attributes.should == { plain: 'yup' }
    end
  end

  describe 'registering a collection' do
    before do
      model_class = Class.new(Travis::Settings::Model) {
        attribute :name, String
      }
      collection_class = Class.new(Travis::Settings::Collection) {
        model model_class
      }
      Travis::Settings.const_set('Items', collection_class)
    end

    after do
      Travis::Settings.send(:remove_const, 'Items')
    end


    it 'allows to register a collection' do
      settings_class = Class.new(Travis::Settings) {
        attribute :items, Travis::Settings::Items.for_virtus
      }
      settings = settings_class.new

      settings.items.to_a.should == []
      settings.items.class.should == Travis::Settings::Items
    end

    it 'populates registered collections from raw settings' do
      settings_class = Class.new(Travis::Settings) {
        attribute :items, Travis::Settings::Items.for_virtus
      }

      settings = settings_class.new items: [{ name: 'one' }, { name: 'two' }]
      settings.items.map(&:name).should == ['one', 'two']
    end
  end

  it 'allows to load from nil' do
    settings = Travis::Settings.new(nil)
    settings.to_hash == {}
  end

  describe 'save' do
    it 'runs on_save callback' do
      on_save_performed = false
      settings = Travis::Settings.new('foo' => 'bar').on_save { on_save_performed = true }
      settings.save

      on_save_performed.should be_true
    end

    it 'does not run on_save callback if settings are not valid' do
      on_save_performed = false
      settings = Travis::Settings.new.on_save { on_save_performed = true }
      settings.stubs(:valid?).returns(false)
      settings.save.should be_false

      on_save_performed.should be_false
    end
  end

  describe 'to_hash' do
    it 'returns registered collections and all attributes' do
      model_class = Class.new(Travis::Settings::Model) {
        attribute :id, String
        attribute :name, String
        attribute :content, Travis::Settings::EncryptedValue
      }
      collection_class = Class.new(Travis::Settings::Collection) {
        model model_class
      }
      settings_class = Class.new(Travis::Settings) {
        attribute :items, collection_class.for_virtus
        attribute :first_setting,  String
        attribute :second_setting, String, default: 'second setting default'
        attribute :secret, Travis::Settings::EncryptedValue
      }

      settings = settings_class.new(first_setting: 'a value')
      settings.secret = '44'

      item = settings.items.create(name: 'foo', content: 'bar')

      hash = settings.to_hash

      column = Travis::Model::EncryptedColumn.new(use_prefix: false)

      hash[:secret].should_not == '44'
      column.load(hash[:secret]).should == '44'

      hash[:first_setting].should == 'a value'
      hash[:second_setting].should == 'second setting default'

      hash_item = hash[:items].first
      hash_item[:id].should == item.id
      hash_item[:name].should == 'foo'
      hash_item[:content].should_not == 'bar'
      column.load(hash_item[:content]).should == 'bar'
    end
  end

  describe '#merge' do
    it 'does not save' do
      settings = Travis::Settings.new
      settings.merge(foo: 'bar')
      settings.expects(:save).never
    end

    it 'merges individual fields' do
      settings_class = Class.new(Travis::Settings) {
        attribute :items, Class.new(Travis::Settings::Collection) {
          model Class.new(Travis::Settings::Model) {
            attribute :name, String
          }
        }.for_virtus
        attribute :foo, String
      }
      settings = settings_class.new(foo: 'bar')
      settings.foo.should == 'bar'

      settings.merge('foo' => 'baz', items: [{ name: 'something' }])

      settings.to_hash[:foo].should == 'baz'
      settings.to_hash[:items].should == []
     end

    it 'does not allow to merge unknown settings' do
      settings = Travis::Settings.new
      settings.merge('possibly_unknown_setting' => 'foo')

      settings.to_hash['possibly_unknown_setting'].should be_nil
    end
  end
end
