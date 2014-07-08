# encoding: utf-8
require 'coercible'
require 'travis/settings'
require 'travis/overwritable_method_definitions'
require 'travis/settings/encrypted_value'

class Repository::Settings < Travis::Settings
  class SshKey < Travis::Settings::Model
    attribute :id, String
    attribute :name, String
    attribute :content, Travis::Settings::EncryptedValue

    validates :name, presence: true
  end

  class SshKeys < Collection
    model SshKey
  end

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

  class CampfireRoom < Travis::Settings::Model
    attribute :id, String
    attribute :subdomain, String
    attribute :api_token, String
    attribute :room_id, String
    attribute :template, String

    validates :subdomain, :api_token, :room_id, presence: true
  end

  class CampfireRooms < Collection
    model CampfireRoom
  end

  class Campfire < Travis::Settings::Model
    attribute :on_success, String, default: 'change'
    attribute :on_failure, String, default: 'always'
    attribute :template, String

    attribute :rooms, CampfireRooms.for_virtus
  end

  attribute :ssh_keys, SshKeys.for_virtus
  attribute :env_vars, EnvVars.for_virtus

  attribute :campfire, Campfire

  attribute :builds_only_with_travis_yml, Boolean, default: false
  attribute :build_pushes, Boolean, default: true
  attribute :build_pull_requests, Boolean, default: true
  attribute :maximum_number_of_builds, Integer

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
