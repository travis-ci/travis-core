module Travis
  module Model
    module EnvHelpers
      def obfuscate_env(vars)
        Array(vars).map do |var|
          repository.key.secure.decrypt(var) do |decrypted|
            Travis::Helpers.obfuscate_env_vars(decrypted)
          end
        end
      end
    end
  end
end
