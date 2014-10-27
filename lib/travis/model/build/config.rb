require 'pry'
require 'travis/model/build/config/env'
require 'travis/model/build/config/features'
require 'travis/model/build/config/language'
require 'travis/model/build/config/matrix'
require 'travis/model/build/config/obfuscate'
require 'travis/model/build/config/os'
require 'travis/model/build/config/yaml'

class Build
  class Config
    NORMALIZERS = [Features, Yaml, Env, Language, OS]

    DEFAULT_LANG = 'ruby'

    ENV_KEYS = [:rvm, :gemfile, :env, :otp_release, :php, :node_js, :scala, :jdk, :python, :perl, :compiler, :go, :xcode_sdk, :xcode_scheme, :ghc, :ruby, :rust]

    EXPANSION_KEYS_FEATURE = [:os]

    EXPANSION_KEYS_LANGUAGE = {
      'c'           => [:compiler],
      'c++'         => [:compiler],
      'clojure'     => [:lein, :jdk],
      'cpp'         => [:compiler],
      'erlang'      => [:otp_release],
      'go'          => [:go],
      'groovy'      => [:jdk],
      'haskell'     => [:ghc],
      'java'        => [:jdk],
      'node_js'     => [:node_js],
      'objective-c' => [:rvm, :gemfile, :xcode_sdk, :xcode_scheme],
      'perl'        => [:perl],
      'php'         => [:php],
      'python'      => [:python],
      'ruby'        => [:rvm, :gemfile, :jdk, :ruby],
      'rust'        => [:rust],
      'scala'       => [:scala, :jdk]
    }

    EXPANSION_KEYS_UNIVERSAL = [:env, :branch]

    def self.matrix_keys_for(config, options = {})
      keys = matrix_keys(config, options)
      keys & config.keys.map(&:to_sym)
    end

    def self.matrix_keys(config, options = {})
      lang = Array(config.symbolize_keys[:language]).first
      keys = ENV_KEYS
      keys &= EXPANSION_KEYS_LANGUAGE.fetch(lang, EXPANSION_KEYS_LANGUAGE[DEFAULT_LANG])
      keys << :os if options[:multi_os]
      keys += [:dist, :group] if options[:dist_group_expansion]
      keys | EXPANSION_KEYS_UNIVERSAL
    end

    attr_reader :config, :options

    def initialize(config, options = {})
      @config = (config || {}).deep_symbolize_keys
      @options = options
    end

    def normalize
      NORMALIZERS.inject(config) do |config, normalizer|
        normalizer.new(config, options).run
      end
    end

    def obfuscate
      Obfuscate.new(config, options).run
    end
  end
end
