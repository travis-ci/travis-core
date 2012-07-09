module Travis
  module Model
    module EnvHelpers
      def obfuscate_env_vars(env_vars)
          Array(env_vars).map do |env|
          repository.key.secure.decrypt(env) do |decrypted|
            env = Travis::Helpers.obfuscate_env_vars(decrypted)
          end

          env
        end.join(' ')
      end
    end
  end
end
