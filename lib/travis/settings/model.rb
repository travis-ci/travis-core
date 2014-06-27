require 'travis/settings/field'
require 'travis/settings/encrypted_value'

class Travis::Settings
  class Model
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include Travis::OverwritableMethodDefinitions

    class << self
      def inherited(child_class)
        child_class.initialize_fields(fields)
        super
      end

      def initialize_fields(fields)
        @fields = fields.dup
      end

      def fields
        @fields ||= []
      end

      def field(field_name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        if args.length > 1
          raise ArgumentError, "too many arguments"
        end
        type = args.first || :string

        field = Field.new(field_name.to_s, type, options)
        fields << field
        create_field(field)
      end

      def field_by_name(name)
        fields.detect { |f| f.name.to_s == name.to_s }
      end

      def create_field(field)
        define_overwritable_method "#{field.name}" do
          field.get(@_attributes[field.name.to_s], key: key)
        end

        define_overwritable_method "#{field.name}=" do |value|
          @_attributes[field.name.to_s] = field.set(value, key: key)
        end
      end

      def field?(name)
        fields.map(&:name).include? name.to_s
      end
    end

    delegate :field?, to: 'self.class'
    field :id, :uuid

    attr_reader :options

    def initialize(attributes = {}, options = {})
      @options = options
      # TODO: figure out if we want to use different key here
      @options[:key] ||= Travis.config.encryption.key
      @_attributes = {}
      if @options[:load]
        load_from_json(attributes)
      else
        update(attributes)
      end
    end

    def load_from_json(attributes)
      return unless attributes

      attributes.each do |attribute, value|
        @_attributes[attribute.to_s] = value if field?(attribute)
      end
    end

    def update(attributes)
      return unless attributes

      attributes.each do |attribute, value|
        self.send("#{attribute}=", value) if field?(attribute)
      end
    end

    def read_attribute_for_serialization(name)
      self.send(name) if field?(name)
    end

    def read_attribute_for_validation(name)
      return unless field?(name)

      value = self.send(name)
      value.is_a?(EncryptedValue) ? value.to_s : value
    end

    def errors
      @errors ||= Errors.new(self)
    end

    def key
      options[:key]
    end

    def to_hash
      hash = {}
      self.class.fields.each do |field|
        hash[field.name] = self.send(field.name)
      end
      hash
    end

    def to_json
      to_hash.to_json
    end
  end
end
