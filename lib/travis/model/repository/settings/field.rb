require 'travis/model/repository/settings/encrypted_value'

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
    attr_reader :encrypted, :default
    alias encrypted? encrypted

    def initialize(name, type, options)
      super
      @encrypted = true if options[:encrypted] || options['encrypted']
      @default = options[:default]
    end

    def set(value, options = {})

      encrypt(coerce(value), options[:key])
    end

    def get(value, options = {})
      wrap_as_encrypted(coerce(value), options[:key])
    end

    def coerce(value)
      return value unless value
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
end
