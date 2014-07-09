# encoding: utf-8
require 'coercible'
require 'travis/settings'
require 'travis/overwritable_method_definitions'
require 'travis/settings/encrypted_value'

class Repository::Settings < Travis::Settings
  class EnvVar < Travis::Settings::Model
    attribute :id, String
    attribute :name, String
    attribute :value, Travis::Settings::EncryptedValue
    attribute :public, Boolean, default: false

    validates :name, presence: true
  end

  class EnvVars < Collection
    model EnvVar
  end

  attribute :env_vars, EnvVars.for_virtus

  attribute :builds_only_with_travis_yml, Boolean, default: false
  attribute :build_pushes, Boolean, default: true
  attribute :build_pull_requests, Boolean, default: true
  attribute :maximum_number_of_builds, Integer
  attribute :ssh_key, Travis::Settings::EncryptedValue

  def maximum_number_of_builds
    super.to_i
  end

  def restricts_number_of_builds?
    maximum_number_of_builds > 0
  end
end

class Repository::DefaultSettings < Repository::Settings
  include Travis::DefaultSettings
end
