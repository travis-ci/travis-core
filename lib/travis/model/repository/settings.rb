# encoding: utf-8

class Repository::Settings
  def self.load(repository, json_string)
    self.new(repository, json_string ? JSON.parse(json_string) : {})
  end

  def initialize(repository, settings)
    self.repository = repository
    self.settings = settings
  end

  attr_accessor :settings, :repository

  delegate :to_json, :[], to: :settings

  def to_hash
    settings
  end

  def merge(json)
    remove_asterisks(json)
    settings.deep_merge!(json)
    save
  end

  def replace(settings)
    self.settings = settings || {}
    save
  end

  def obfuscated
    obfuscate(settings)
  end

  def []=(key, val)
    settings[key] = val
    save
  end

  def save
    repository.settings = self.to_json
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
