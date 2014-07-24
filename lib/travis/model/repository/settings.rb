# encoding: utf-8
require 'coercible'
require 'travis/settings'
require 'travis/overwritable_method_definitions'
require 'travis/settings/encrypted_value'
require 'openssl'

class Repository::Settings < Travis::Settings
  class EnvVar < Travis::Settings::Model
    attribute :id, String
    attribute :name, String
    attribute :value, Travis::Settings::EncryptedValue
    attribute :public, Boolean, default: false
    attribute :repository_id, Integer

    validates :name, presence: true
  end

  class SshKey < Travis::Settings::Model
    attribute :description, String
    attribute :value, Travis::Settings::EncryptedValue
    attribute :repository_id, Integer

    validates :value, presence: true
    validate :validate_correctness

    def validate_correctness
      OpenSSL::PKey::RSA.new(value.decrypt)
    rescue OpenSSL::PKey::RSAError
      errors.add(:value, :not_private_key)
    end
  end

  class EnvVars < Collection
    model EnvVar
  end

  attribute :env_vars, EnvVars.for_virtus

  attribute :builds_only_with_travis_yml, Boolean, default: false
  attribute :build_pushes, Boolean, default: true
  attribute :build_pull_requests, Boolean, default: true
  attribute :maximum_number_of_builds, Integer
  attribute :ssh_key, SshKey

  validates :maximum_number_of_builds, numericality: true

  def maximum_number_of_builds
    super || 0
  end

  def restricts_number_of_builds?
    maximum_number_of_builds > 0
  end
end

class Repository::DefaultSettings < Repository::Settings
  include Travis::DefaultSettings
end
