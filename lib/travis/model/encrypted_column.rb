require 'securerandom'

module Travis::Model
  class EncryptedColumn
    def load(data)
      return nil unless data

      data = data.to_s

      decrypt?(data) ? decrypt(data) : data
    end

    def dump(data)
      encrypt? ? encrypt(data.to_s) : data
    end

    def key
      ENV['DB_ENCRYPTION_KEY']
    end

    def iv
      SecureRandom.hex(8)
    end

    def prefix
      '--ENCR--'
    end

    def decrypt?(data)
      !use_prefix? || prefix_used?(data)
    end

    def encrypt?
      Travis::Features.feature_active?(:db_encryption)
    end

    def prefix_used?(data)
      data[0..7] == prefix
    end

    def decrypt(data)
      data = data[8..-1] if prefix_used?(data)

      iv   = data[-16..-1]
      data = data[0..-17]

      aes = create_aes :decrypt, key, iv

      aes.update(data) + aes.final
    end

    def encrypt(data)
      iv = self.iv

      aes = create_aes :encrypt, key, iv

      encrypted = aes.update(data) + aes.final

      encrypted = "#{encrypted}#{iv}"
      encrypted = "#{prefix}#{encrypted}" if use_prefix?
      encrypted
    end

    def use_prefix?
      Travis::Features.feature_active?(:db_encryption_prefix)
    end

    def create_aes(mode = :encrypt, key, iv)
      aes = OpenSSL::Cipher.new("AES-256-CFB")

      aes.send(mode)
      aes.key = key
      aes.iv  = iv

      aes
    end
  end
end
