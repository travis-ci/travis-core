# encoding: utf-8
require 'coercible'
require 'travis/overwritable_method_definitions'
require 'travis/model/repository/settings/collection'
require 'travis/model/repository/settings/model'

class Repository::Settings
  SETTINGS = []

  class SshKey < Model
    field :name
    field :content, encrypted: true

    validates :name, presence: true
  end

  class SshKeys < Collection
    model SshKey
  end

  class EnvVar < Model
    field :name
    field :value, encrypted: true

    validates :name, presence: true
  end

  class EnvVars < Collection
    model EnvVar
  end

  include Travis::OverwritableMethodDefinitions

  class << self
    def load(repository, json_string)
      new(repository, json_string ? JSON.parse(json_string) : {})
    end

    def register(path, collection_class_or_name = nil)
      path = path.to_s

      collection_class_or_name ||= path
      klass = if collection_class_or_name.is_a?(String) || collection_class_or_name.is_a?(Symbol)
        name = collection_class_or_name.to_s.camelize
        Repository::Settings.const_get(name, false)
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

    def setting?(name)
      SETTINGS.detect { |s| s.name.to_s == name.to_s }
    end

    def add_setting(name, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      if args.length > 1
        raise ArgumentError, "too many arguments"
      end
      type = args.first || :string
      field = Field.new(name.to_s, type, options)
      SETTINGS << field

      method_name = field.name.dup
      method_name << '?' if field.type == :boolean

      define_overwritable_method method_name do
        field.get(get(field.name.to_s))
      end

      define_overwritable_method "#{field.name}=" do |value|
        set(field.name.to_s, field.set(value))
      end
    end
  end

  register :ssh_keys
  register :env_vars

  attr_accessor :collections, :settings

  def initialize(repository, settings)
    self.repository = repository
    self.settings = settings || {}
    initialize_collections
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
  delegate :setting?, :defaults, :defaults=, to: 'self.class'

  add_setting :builds_only_with_travis_yml, :boolean, default: false
  add_setting :build_pushes, :boolean, default: true
  add_setting :build_pull_requests, :boolean, default: true
  add_setting :maximum_number_of_builds, :integer

  def maximum_number_of_builds
    super.to_i
  end

  def restricts_number_of_builds?
    maximum_number_of_builds > 0
  end

  class << self
    def defaults
      Hash[*SETTINGS.find_all { |s| !s.default.nil? }.map { |s| [s.name, s.default] }.flatten]
    end
  end

  def get(path)
    current = to_hash
    path.split('.').take_while { |key| current = current[key] }
    current
  end
  private :get

  def set(key, value)
    if key[/\./]
      raise ArgumentError.new("set doesn't support paths at thie point, sorry :(")
    end

    if setting?(key)
      settings[key] = value
    end
  end
  private :set

  def to_hash
    only_allowed_settings(defaults.deep_merge(settings))
  end

  def defaults
    self.class.defaults
  end

  def merge(json)
    only_allowed_settings(json).each { |k, v|
      set(k, v)
    }
    save
  end

  def replace(settings)
    self.settings = settings || {}
    save
  end

  def obfuscated
    to_hash
  end

  def [](key)
    to_hash[key]
  end

  def []=(key, val)
    settings[key] = val
    save
  end

  def save
    # TODO: this class started as a thin wrapper over hash,
    #       this part could be refactored to not rely on the
    #       hash, but rather on the structured data like collections
    #       and fields
    collections.each do |collection|
      if @settings[collection.registered_at] || !collection.empty?
        @settings[collection.registered_at] = collection.to_hashes
      end
    end

    repository.settings = settings.to_json
    repository.save!
  end

  def only_allowed_settings(hash)
    hash.slice(*SETTINGS.map(&:name))
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
