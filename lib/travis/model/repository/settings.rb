# encoding: utf-8
require 'coercible'
require 'travis/overwritable_method_definitions'

class Repository::Settings
  class Errors < ActiveModel::Errors
    # Default behavior of Errors in Active Model is to
    # translate symbolized message into full text message,
    # using i18n if available. I don't want such a behavior,
    # as I want to return error "codes" like :blank, not
    # full text like "can't be blank"
    def normalize_message(attribute, message, options)
      message || :invalid
    end
  end

  class Field < Struct.new(:name, :type, :options)
    attr_reader :encrypted
    alias encrypted? encrypted

    def initialize(name, type, options)
      super
      @encrypted = true if options[:encrypted] || options['encrypted']
    end

    def set(value, options)
      encrypt(coerce(value), options[:key])
    end

    def get(value, options)
      wrap_as_encrypted(value, options[:key])
    end

    def coerce(value)
      coercer = Coercible::Coercer.new
      coercer[value.class].send(coercer_method, value)
    end

    def coercer_method
      if type == :uuid
        'to_string'
      else
        "to_#{type}"
      end
    end

    def wrap_as_encrypted(value, key)
      encrypted? ? EncryptedValue.new(value, key) : value
    end

    def encrypt(value, key)
      if encrypted?
        Travis::Model::EncryptedColumn.new(key: key, use_prefix: false).dump(value)
      else
        value
      end
    end
  end

  class EncryptedValue
    attr_reader :value, :key
    def initialize(value, key)
      @value = value
      @key = key
    end

    def to_s
      value
    end

    def to_str
      value
    end

    def to_json
      value.to_json
    end

    def as_json(*)
      value
    end

    def decrypt
      Travis::Model::EncryptedColumn.new(key: key, use_prefix: false).load(value)
    end
  end

  class Model
    include ActiveModel::Validations
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
          field.get(self.instance_variable_get("@#{field.name}"), key: key)
        end

        define_overwritable_method "#{field.name}=" do |value|
          self.instance_variable_set("@#{field.name}", field.set(value, key: key))
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
      attributes.each do |attribute, value|
        self.send("#{attribute}=", value) if field?(attribute)
      end
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

  class Collection
    include Enumerable

    class << self
      def model(model_name_or_class = nil)
        if model_name_or_class
          klass = if model_name_or_class.is_a?(String) || model_name_or_class.is_a?(Symbol)
            name = model_name_or_class.to_s.classify
            Repository::Settings.const_get(name)
          else
            model_name_or_class
          end

          @model_class = klass
        else
          @model_class
        end
      end
      attr_reader :model_class
    end

    attr_reader :collection
    attr_accessor :registered_at
    delegate :model_class, to: 'self.class'
    delegate :each, :length, :empty?, to: :collection

    def initialize
      @collection = []
    end

    def create(attributes)
      model = model_class.new(attributes)
      model.id = SecureRandom.uuid unless model.id
      collection.push model
      model
    end

    def load(array)
      array.each do |attributes|
        model = model_class.new(attributes)
        collection.push model
      end
    end

    def to_hashes
      collection.map(&:to_hash)
    end
  end

  class SshKey < Model
    field :name
    field :content, encyrpt: true

    validates :name, presence: true
  end

  class SshKeys < Collection
    model SshKey
  end

  include Travis::OverwritableMethodDefinitions

  class << self
    def load(repository, json_string)
      new(repository, json_string ? JSON.parse(json_string) : {})
    end

    def register(path, collection_class_or_name = nil)
      path = path.to_s
      @collections ||= {}

      collection_class_or_name ||= path
      klass = if collection_class_or_name.is_a?(String) || collection_class_or_name.is_a?(Symbol)
        name = collection_class_or_name.to_s.camelize
        Repository::Settings.const_get(name)
      else
        collection_class_or_name
      end

      @collections[path] = klass

      define_overwritable_method "#{path}" do
        instance_variable_get("@#{path}")
      end
    end
    attr_reader :collections
  end

  register :ssh_keys

  attr_accessor :collections

  def initialize(repository, settings)
    self.repository = repository
    self.settings = settings || {}
    initialize_collections
  end

  def settings
    # TODO: this class started as a thin wrapper over hash,
    #       this part could be refactored to not rely on the
    #       hash, but rather on the structured data like collections
    #       and fields
    collections.each do |collection|
      @settings[collection.registered_at] = collection.to_hashes unless collection.empty?
    end

    @settings
  end

  def initialize_collections
    self.collections = []
    self.class.collections.each do |path, klass|
      collection = klass.new
      collection.registered_at = path
      collection.load(settings[path]) if settings[path]
      instance_variable_set("@#{path}", collection)
      collections.push(collection)
    end
  end

  attr_writer :settings
  attr_accessor :repository

  delegate :to_json, :[], to: :settings
  delegate :defaults, :defaults=, to: 'self.class'

  def builds_only_with_travis_yml?
    get('builds_only_with_travis_yml')
  end

  def build_pushes?
    get('build_pushes')
  end

  def build_pull_requests?
    get('build_pull_requests')
  end

  class << self
    def defaults
      {
        'builds_only_with_travis_yml' => false,
        'build_pushes' => true,
        'build_pull_requests' => true
      }
    end
  end

  def get(path)
    current = to_hash
    path.split('.').take_while { |key| current = current[key] }
    current
  end

  def to_hash
    defaults.deep_merge(settings)
  end

  def defaults
    self.class.defaults
  end

  def merge(json)
    remove_asterisks(json)
    settings.deep_merge!(json)
    save
  end

  def replace(settings)
    remove_asterisks(settings)
    self.settings = settings || {}
    save
  end

  def obfuscated
    obfuscate(to_hash)
  end

  def [](key)
    to_hash[key]
  end

  def []=(key, val)
    settings[key] = val
    save
  end

  def save
    repository.settings = settings.to_json
    repository.save
  end

  private

  def remove_asterisks(item)
    if item.is_a?(Hash)
      item.dup.each_pair do |k, v|
        if v.respond_to?(:=~) && v =~ /∗/
          item.delete(k)
        else
          item[k] = remove_asterisks(v)
        end
      end
    elsif item.is_a?(Array)
      item.reject { |v| v.respond_to?(:=~) && v =~ /∗/ }.map { |v| remove_asterisks(v) }
    else
      item
    end
  end

  def obfuscate(item)
    item = item.dup if item.duplicable?

    if item.is_a?(Hash)
      if item['type'] && item['type'] == 'password' && item['value'].respond_to?(:gsub)
        item['value'] = item['value'].gsub(/./, '∗')
      else
        item.dup.each_pair { |k, v| item[k] = obfuscate(v) }
      end
    elsif item.is_a?(Array)
      item.map! { |e| obfuscate(e) }
    end

    item
  end
end

class Repository::DefaultSettings < Repository::Settings
  def initialize
    self.settings = {}
    self.collections = []
  end

  def merge(*)
    raise "merge is not supported on default settings"
  end

  def replace(*)
    raise "replace is not supported on default settings"
  end

  def []=(*)
    raise "setting values is not supported on default settings"
  end
end
