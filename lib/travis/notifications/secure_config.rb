require 'base64'

module Travis
  module Notifications
    class SecureConfig
      attr_reader :key

      def self.decrypt(config, key)
        self.new(key).decrypt(config)
      end

      def initialize(key)
        @key = key
      end

      def decrypt(config)
        return config if config.is_a?(String)

        config.inject(config.class.new) do |result, element|
          key, element = element if result.is_a?(Hash)

          value = decrypt_element(key, element)

          process_result(result, key, value)
        end
      end

      private

      def decrypt_element(key, element)
        if element.is_a?(Array)
          value = decrypt(element)
        elsif element.is_a?(Hash)
          value = decrypt(element)
        elsif key == :secure
          value = decrypt_value(element)
        else
          value = element
        end
      end

      def process_result(result, key, value)
        if result.is_a?(Array)
          result << value
        elsif result.is_a?(Hash) && !secure_key?(key)
          result[key] = value
          result
        else
          value
        end
      end

      def decrypt_value(value)
        decoded = Base64.decode64(value)
        key.decrypt(decoded)
      rescue OpenSSL::PKey::RSAError
        value
      end

      def secure_key?(key)
        key && key == :secure
      end
    end
  end
end
