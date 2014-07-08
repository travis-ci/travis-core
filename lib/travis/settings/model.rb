require 'virtus'
require 'travis/settings/encrypted_value'
require 'travis/settings/model_extensions'

class Travis::Settings
  class Model
    include Virtus.model
    include ModelExtensions
    include ActiveModel::Validations
    include ActiveModel::Serialization

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

    def attribute?(name)
      attributes.keys.include?(name.to_sym)
    end

    def read_attribute_for_serialization(name)
      self.send(name) if attribute?(name)
    end

    def read_attribute_for_validation(name)
      return unless attribute?(name)

      value = self.send(name)
      value.is_a?(EncryptedValue) ? value.to_s : value
    end

    def errors
      @errors ||= Errors.new(self)
    end

    def update(attributes)
      self.attributes = attributes
    end

    def key
      Travis.config.encryption.key
    end

    def to_json
      to_hash.to_json
    end
  end
end
