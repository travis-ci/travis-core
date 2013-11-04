module Travis
  class Config
    class Env
      def load
        ENV['travis_config'] ? YAML.load(ENV['travis_config']) : {}
      end
    end
  end
end
