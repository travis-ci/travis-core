require 'spec_helper'

describe Repository::Settings::Model do
  before do
    @model_class = Class.new(described_class) do
      field :name
      field :loves_travis, :boolean
      field :height, :integer
    end
  end

  it 'creates an instance with attributes' do
    model = @model_class.new(name: 'Piotr', loves_travis: true, height: 178)
    model.name.should == 'Piotr'
    model.loves_travis.should be_true
    model.height.should == 178
  end

  it 'allows to overwrite values' do
    model = @model_class.new(name: 'Piotr')
    model.name = 'Peter'
    model.name.should == 'Peter'
  end

  it 'coerces values by default' do
    model = @model_class.new(height: '178', loves_travis: 'true')
    model.height.should == 178
    model.loves_travis.should == true
  end

  it 'allows to override attribute methods' do
    @model_class.class_eval do
      def name
        super.upcase
      end
    end

    model = @model_class.new(name: 'piotr')
    model.name.should == 'PIOTR'
  end

  it 'automatically generates id field' do
    field = @model_class.field('id')
    field.should_not be_nil
    field.type.should == :uuid
  end
end
