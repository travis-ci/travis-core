require "keen"

module Travis
  class TravisYmlStats
    LANGUAGE_VERSION_KEYS = %w[
      ghc
      go
      jdk
      node_js
      otp_release
      perl
      php
      python
      ruby
      rvm
      scala
    ]

    def self.keen_client=(keen_client)
      @keen_client = keen_client
    end

    def self.store_stats(request, keen_client=@keen_client || Keen)
      new(request, keen_client).store_stats
    end

    def initialize(request, keen_client)
      @request = request
      @keen_client = keen_client
      @keen_payload = {}
    end

    def store_stats
      set_basic_info
      set_language
      set_language_version
      set_uses_sudo
      set_uses_apt_get

      @keen_client.publish(:requests, keen_payload)
    end

    private

    attr_reader :request, :keen_payload

    def set(path, value)
      path = Array(path)
      hsh = keen_payload
      path[0..-2].each do |key|
        hsh[key.to_sym] ||= {}
        hsh = hsh[key.to_sym]
      end

      hsh[path.last.to_sym] = value
    end

    def set_basic_info
      set :repository_id, request.repository_id
    end

    def set_language
      set :language, travis_yml_language
      set :github_language, github_language
    end

    def set_language_version
      LANGUAGE_VERSION_KEYS.each do |key|
        if config.key?(key)
          case config[key]
          when String, Array
            set [:language_version, key], Array(config[key]).sort
          else
            set [:language_version, key], ["invalid"]
          end
        end
      end
    end

    def set_uses_sudo
      set :uses_sudo, commands.any? { |command| command =~ /\bsudo\b/ }
    end

    def set_uses_apt_get
      set :uses_apt_get, commands.any? { |command| command =~ /\bapt-get\b/ }
    end

    def config
      request.config
    end

    def payload
      request.payload
    end

    def commands
      [
        config["before_install"],
        config["install"],
        config["before_script"],
        config["script"],
        config["after_success"],
        config["after_failure"],
        config["before_deploy"],
        config["after_deploy"],
      ].flatten.compact
    end

    def travis_yml_language
      language = config["language"]
      case language
      when Array
        "invalid"
      else
        language
      end
    end

    def github_language
      payload.fetch("repository", {})["language"]
    end

    def normalize_string(str)
      str.downcase.gsub("#", "-sharp").gsub(/[^A-Za-z0-9.:\-_]/, "")
    end
  end
end
