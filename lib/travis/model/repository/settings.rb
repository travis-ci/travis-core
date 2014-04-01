# encoding: utf-8
require 'coercible'
require 'travis/overwritable_method_definitions'
require 'travis/model/repository/settings/collection'
require 'travis/model/repository/settings/model'

class Repository::Settings
  class SshKey < Model
    field :name
    field :content, encrypted: true

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
