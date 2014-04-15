require 'spec_helper'

describe Repository::Settings::Collection do
  describe 'collection with polymorphic model' do
    before do
      @entry_class = Class.new(Repository::Settings::Model) {
        polymorphic

        field :name
      }

      @movie_class = Class.new(@entry_class) {
        field :director
      }

      @book_class = Class.new(@entry_class) {
        field :author
      }

      Repository::Settings.const_set('Entry', @entry_class)
      Repository::Settings.const_set('Movie', @movie_class)
      Repository::Settings.const_set('Book',  @book_class)

      @entries_class = Class.new(described_class) do
        model :entry
      end
    end

    after do
      Repository::Settings.send(:remove_const, 'Entry')
      Repository::Settings.send(:remove_const, 'Movie')
      Repository::Settings.send(:remove_const, 'Book')
    end

    it 'loads models from JSON based on given type' do
      json = [{ id: '1', name: 'Game of Thrones', author: 'George R.R. Martin', type: 'book' },
              { id: '2', name: 'Blade Runner', director: 'Ridley Scott', type: 'movie'}]

      collection = @entries_class.new
      collection.load(json)

      book  = collection.find('1')
      movie = collection.find('2')

      book.name.should == 'Game of Thrones'
      book.author.should == 'George R.R. Martin'
      book.type.should == 'book'
      book.class.should == @book_class

      movie.name.should == 'Blade Runner'
      movie.director.should == 'Ridley Scott'
      movie.type.should == 'movie'
      movie.class.should == @movie_class
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

    describe '#destroy' do
      it 'removes an item from collection' do
        collection = @collection_class.new
        item = collection.create(description: 'foo')

        collection.should have(1).item

        collection.destroy(item.id)

        collection.should have(0).items
      end
    end

    describe '#find' do
      it 'finds an item' do
        collection = @collection_class.new
        item = collection.create(description: 'foo')

        collection.should have(1).item

        collection.find(item.id).should == item
        collection.find('foobarbaz').should be_nil
      end
    end
  end

  describe 'regular collection' do
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

    describe '#destroy' do
      it 'removes an item from collection' do
        collection = @collection_class.new
        item = collection.create(description: 'foo')

        collection.should have(1).item

        collection.destroy(item.id)

        collection.should have(0).items
      end
    end

    describe '#find' do
      it 'finds an item' do
        collection = @collection_class.new
        item = collection.create(description: 'foo')

        collection.should have(1).item

        collection.find(item.id).should == item
        collection.find('foobarbaz').should be_nil
      end
    end
  end
end
