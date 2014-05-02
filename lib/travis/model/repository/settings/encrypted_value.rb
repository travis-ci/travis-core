class Repository::Settings
  class EncryptedValue
    attr_reader :value, :key
    def initialize(value, key)
      @value = value
      @key = key
    end

    def to_s
      value
    end

    def to_str
      value
    end

    def to_json
      value.to_json
    end

    def as_json(*)
      value
    end

    def inspect
      "<Repository::Settings::EncryptedValue##{object_id}>"
    end

    def decrypt
      Travis::Model::EncryptedColumn.new(key: key, use_prefix: false).load(value)
    end
  end
end
