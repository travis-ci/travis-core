module Travis
  module Model
    module EnvHelpers
      def obfuscate_env_vars(env_vars)
        Array(env_vars).map do |env|
          repository.key.secure.decrypt(env) do |decrypted|
            Travis::Helpers.obfuscate_env_vars(decrypted)
          end
        end
      end
    end
  end
end
