# encoding: utf-8
require 'coercible'

class Repository::Settings
  class Field < Struct.new(:name, :type, :options)
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
  end

  class Model
    class << self
      def inherited(child_class)
        child_class.initialize_attributes_module
        super
      end

      def initialize_attributes_module
        @generated_attribute_methods = Module.new
        include @generated_attribute_methods
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

      def create_field(field)
        @generated_attribute_methods.send :define_method, "#{field.name}" do
          self.instance_variable_get("@#{field.name}")
        end

        @generated_attribute_methods.send :define_method, "#{field.name}=" do |value|
          self.instance_variable_set("@#{field.name}", field.coerce(value))
        end
      end

      def field?(name)
        fields.map(&:name).include? name.to_s
      end
    end

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        self.send("#{attribute}=", value) if self.class.field?(attribute)
      end
    end
  end

  class Collection
    class << self
      def model(model_name_or_class = nil)
        if model_name_or_class
          klass = if model_name_or_class.is_a?(String) || model_name_or_class.is_a?(Symbol)
            name = model_name_or_class.to_s.classify
            Repository::Settings.const_get(name)
          else
            model_name_or_class
          end

          @model = klass
        else
          @model
        end
      end
    end
  end

  class SshKey < Model
    field :name
    field :content, encyrpt: true
  end

  class SshKeys < Collection
    model SshKey
  end

  def self.load(repository, json_string)
    self.new(repository, json_string ? JSON.parse(json_string) : {})
  end

  def initialize(repository, settings)
    self.repository = repository
    self.settings = settings || {}
  end

  attr_accessor :settings, :repository

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
