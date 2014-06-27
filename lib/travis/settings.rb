require 'coercible'
require 'travis/overwritable_method_definitions'
require 'travis/settings/collection'
require 'travis/settings/model'

module Travis
  class Settings
    include Travis::OverwritableMethodDefinitions

    class << self
      def load(json_string)
        new(json_string ? JSON.parse(json_string) : {})
      end

      def register(path, collection_class_or_name = nil)
        path = path.to_s

        collection_class_or_name ||= path
        klass = if collection_class_or_name.is_a?(String) || collection_class_or_name.is_a?(Symbol)
          name = collection_class_or_name.to_s.camelize
          if self.const_defined?(name, false)
            self.const_get(name, false)
          else
            Travis::Settings.const_get(name, false)
          end
        else
          collection_class_or_name
        end

        collections[path] = klass

        define_overwritable_method "#{path}" do
          instance_variable_get("@#{path}")
        end
      end

      def collections
        @collections ||= {}
      end

      def settings
        @settings ||= []
      end

      def setting?(name)
        settings.detect { |s| s.name.to_s == name.to_s }
      end

      def add_setting(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        if args.length > 1
          raise ArgumentError, "too many arguments"
        end
        type = args.first || :string
        field = Field.new(name.to_s, type, options)
        settings << field

        method_name = field.name.dup
        method_name << '?' if field.type == :boolean

        define_overwritable_method method_name do
          field.get(get(field.name.to_s))
        end

        define_overwritable_method "#{field.name}=" do |value|
          set(field.name.to_s, field.set(value))
        end
      end

      def defaults
        Hash[*settings.find_all { |s| !s.default.nil? }.map { |s| [s.name, s.default] }.flatten]
      end
    end

    attr_accessor :collections, :attributes

    def initialize(settings = {})
      settings ||= {}
      settings.stringify_keys!
      initialize_attributes(settings)
      initialize_collections(settings)
    end

    def on_save(&block)
      @on_save = block
      self
    end

    def initialize_attributes(settings)
      self.attributes = {}
      self.class.settings.each do |setting|
        if settings.has_key? setting.name
          set(setting.name, settings[setting.name])
        end
      end
    end

    def initialize_collections(settings)
      self.collections = []
      self.class.collections.each do |path, klass|
        collection = klass.new
        collection.registered_at = path
        collection.load(settings[path]) if settings[path]
        instance_variable_set("@#{path}", collection)
        collections.push(collection)
      end
    end

    delegate :setting?, :defaults, :defaults=, to: 'self.class'

    def get(key)
      if setting?(key)
        attributes[key]
      end
    end
    private :get

    def set(key, value)
      if setting?(key)
        attributes[key] = value
      end
    end
    private :set

    def to_hash
      settings = {}

      collections.each do |collection|
        if settings[collection.registered_at] || !collection.empty?
          settings[collection.registered_at] = collection.to_hashes
        end
      end

      settings.merge!(attributes)

      defaults.deep_merge(settings)
    end

    def merge(json)
      json.each { |k, v|
        set(k, v)
      }
      save
    end

    def obfuscated
      to_hash
    end

    def save
      @on_save.call
    end

    def to_json
      to_hash.to_json
    end
  end

  module DefaultSettings
    def initialize
      self.collections = []
      self.attributes = {}
    end

    def merge(*)
      raise "merge is not supported on default settings"
    end

    def set(key, value)
      raise "setting values is not supported on default settings"
    end
  end
end
