class Repository::Settings
  class Collection
    include Enumerable

    class << self
      def model(model_name_or_class = nil)
        if model_name_or_class
          klass = if model_name_or_class.is_a?(String) || model_name_or_class.is_a?(Symbol)
            name = model_name_or_class.to_s.classify
            Repository::Settings.const_get(name, false)
          else
            model_name_or_class
          end

          @model_class = klass
        else
          @model_class
        end
      end

      def model_class(attributes = nil)
        attributes ||= {}
        type = attributes['type'] || attributes[:type]
        if @model_class.polymorphic? && type
          @model_class.subclasses.find { |klass| klass.name.split('::').last == type.classify }
        else
          @model_class
        end
      end
    end

    attr_reader :collection
    attr_accessor :registered_at
    delegate :model_class, to: 'self.class'
    delegate :each, :length, :empty?, to: :collection

    def initialize
      @collection = []
    end

    def create(attributes)
      model = model_class(attributes).new(attributes)
      model.id = SecureRandom.uuid unless model.id
      collection.push model
      model
    end

    def load(array)
      array.each do |attributes|
        model = model_class(attributes).new(attributes, load: true)
        collection.push model
      end
    end

    def to_hashes
      collection.map(&:to_hash)
    end

    def find(id)
      collection.detect { |model| model.id == id.to_s }
    end

    def destroy(id)
      record = find(id)
      if record
        collection.delete record
        record
      end
    end
  end
end
