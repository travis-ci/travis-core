# encoding: utf-8
require 'spec_helper'

describe Repository::Settings do
  let(:repo) { stub('repository') }

  describe 'adding a setting' do
    let(:settings_class) {
      Class.new(Repository::Settings) {
        add_setting :an_integer_field, :integer
        add_setting :a_boolean_field, :boolean, default: true
      }
    }

    it 'doesn\'t allow to set or get unknown settings' do
      settings = settings_class.new(repo, {})
      settings.expects(:save)
      settings.merge('foo' => 'bar')

      settings.get('foo').should be_nil
      settings.settings['foo'].should be_nil
    end

    it 'sets false properly as boolean, not changing it to nil' do
       settings = settings_class.new(repo, {})

      settings.a_boolean_field?.should be_true

      settings.a_boolean_field = false
      settings.a_boolean_field?.should == false
    end

    it 'allows to set a property' do
      settings = settings_class.new(repo, {})

      settings.get('an_integer_field').should be_nil

      settings.set('an_integer_field', 1)
      settings.get('an_integer_field').should == 1
      settings.an_integer_field.should == 1
    end

    it 'allows to set a property using accessor' do
      settings = settings_class.new(repo, {})

      settings.get('an_integer_field').should be_nil

      settings.an_integer_field = 1
      settings.get('an_integer_field').should == 1
      settings.an_integer_field.should == 1
    end
  end

  describe 'registering a collection' do
    before do
      model_class = Class.new(Repository::Settings::Model) {
        field :name
      }
      collection_class = Class.new(Repository::Settings::Collection) {
        model model_class
      }
      Repository::Settings.const_set('Items', collection_class)
    end

    after do
      Repository::Settings.send(:remove_const, 'Items')
    end


    it 'allows to register a collection' do
      settings_class = Class.new(Repository::Settings) {
        register :items
      }
      settings = settings_class.new repo, {}

      settings.items.to_a.should == []
      settings.items.class.should == Repository::Settings::Items
    end

    it 'populates registered collections from raw settings' do
      settings_class = Class.new(Repository::Settings) {
        register :items
      }

      settings = settings_class.new repo, 'items' => [{ 'name' => 'one' }, { 'name' => 'two' }]
      settings.items.map(&:name).should == ['one', 'two']
    end
  end

  it 'allows to load from nil' do
    settings = Repository::Settings.new(repo, nil)
    settings.to_hash == {}
  end

  describe 'save' do
    it 'saves settings to the repository' do
      repo.expects('settings=').with({'foo' => 'bar'}.to_json)
      repo.expects('save!')

      settings = Repository::Settings.new(repo, 'foo' => 'bar')
      settings.save
    end

    it 'saves registered collections' do
      model_class = Class.new(Repository::Settings::Model) {
        field :name
        field :content, encrypted: true
      }
      collection_class = Class.new(Repository::Settings::Collection) {
        model model_class
      }
      settings_class = Class.new(Repository::Settings) {
        register :items, collection_class
      }

      settings = settings_class.new(repo, {})

      item = settings.items.create(name: 'foo', content: 'bar')

      repo.expects('settings=').with() { |json|
        hash = JSON.parse(json)
        column = Travis::Model::EncryptedColumn.new(use_prefix: false)
        decrypted = column.load(hash['items'].first['content'])
        decrypted == 'bar'
      }
      repo.expects('save!')
      settings.save
    end
  end

  describe '#merge' do
    it 'merges individual fields' do
      json = {
        'build_pushes' => true
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:save)
      settings.merge('build_pushes' => false)

      settings.settings['build_pushes'].should == false
     end

    it 'does not allow to merge unknown settings' do
      settings = Repository::Settings.new(repo, {})
      settings.expects(:save)
      settings.merge('possibly_unknown_setting' => 'foo')

      settings.settings['possibly_unknown_setting'].should be_nil
    end
  end

  describe 'to_hash' do
    it 'returns defaults, overwritten by settings - only basic settings' do
      json = {
        'builds_only_with_travis_yml' => true
      }
      settings = Repository::Settings.new(repo, json)

      settings.expects(:defaults).returns(
        'builds_only_with_travis_yml' => false,
        'build_pushes' => true,
        'something_else' => true
      )

      settings.to_hash.should == {
        'builds_only_with_travis_yml' => true,
        'build_pushes' => true,
      }
    end
  end
end
