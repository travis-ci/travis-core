module Travis

  class DecryptConfig
    attr_reader :repository

    def self.run(config, repository)
      self.new(repository).run(config)
    end

    def initialize(repository)
      @repository = repository
    end

    def run(config, r=false)
      return decrypt(config) if config.is_a?(String)
      return config unless config.respond_to?(:inject)
      config.inject(config.class.new) do |result, element|
        key, element = element if result.is_a?(Hash)

        if element.is_a?(Hash) || element.is_a?(Array)
          value = run(element, true)
        else
          value = decrypt(element)
        end

        case result
          when Hash
            result[key] = value
          when Array
            result << value
          else
            result = value
        end

        result
      end
    end

    private
    def decrypt(value)
      if value.respond_to?(:match) && match = value.match(/^secure\:(.*)$/im)
        repository.key.decrypt(match[1])
      else
        value
      end
    rescue OpenSSL::PKey::RSAError
      value
    end
  end
end
