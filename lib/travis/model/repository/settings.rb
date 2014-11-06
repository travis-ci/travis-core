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
    class NotAPrivateKeyError < StandardError; end

    KEY_CLASSES = [
      OpenSSL::PKey::RSA,
      OpenSSL::PKey::DSA,
      OpenSSL::PKey::EC,
    ]

    attribute :description, String
    attribute :value, Travis::Settings::EncryptedValue
    attribute :repository_id, Integer

    validates :value, presence: true
    validate :validate_correctness

    def validate_correctness
      return unless value.decrypt

      unless KEY_CLASSES.any? { |pkey_class| validate_pkey(pkey_class, value.decrypt) }
        if value.decrypt.to_s =~ /ENCRYPTED/
          errors.add(:value, :key_with_a_passphrase)
        else
          errors.add(:value, :not_a_private_key)
        end
      end
    end

    private

    def validate_pkey(pkey_class, key_string)
      key = pkey_class.new(key_string, '')
      key.respond_to?(:private_key?) ? key.private_key? : key.private?
    rescue OpenSSL::PKey::PKeyError
      false
    end
  end

  class EnvVars < Collection
    model EnvVar

    def public
      find_all { |var| var.public? }
    end
  end

  class TimeoutsValidator < ActiveModel::Validator
    def validate(settings)
      [:hard_limit, :log_silence].each do |type|
        next if valid_timeout?(settings, type)
        msg = "Invalid #{type} timout value (allowed: 0 - #{max_value(settings, type)})"
        settings.errors.add :"timeout_#{type}", msg
      end
    end

    private

      def valid_timeout?(settings, type)
        value = settings.send(:"timeout_#{type}")
        value.nil? || value.to_i > 0 && value.to_i <= max_value(settings, type)
      end

      def max_value(settings, type)
        config = Travis.config.settings.timeouts
        values = config.send(custom_timeouts?(settings) ? :maximums : :defaults) || {}
        values[type]
      end

      def custom_timeouts?(settings)
        Travis::Features.repository_active?(:custom_timeouts, settings.repository_id)
      end
  end

  attribute :env_vars, EnvVars.for_virtus

  attribute :builds_only_with_travis_yml, Boolean, default: false
  attribute :build_pushes, Boolean, default: true
  attribute :build_pull_requests, Boolean, default: true
  attribute :maximum_number_of_builds, Integer
  attribute :ssh_key, SshKey
  attribute :timeout_hard_limit
  attribute :timeout_log_silence

  validates :maximum_number_of_builds, numericality: true

  validates_with TimeoutsValidator

  def maximum_number_of_builds
    super || 0
  end

  def restricts_number_of_builds?
    maximum_number_of_builds > 0
  rescue => e
    false
  end

  def timeout_hard_limit
    value = super
    value == 0 ? nil : value
  end

  def timeout_log_silence
    value = super
    value == 0 ? nil : value
  end

  def repository_id
    additional_attributes[:repository_id]
  end
end

class Repository::DefaultSettings < Repository::Settings
  include Travis::DefaultSettings
end
