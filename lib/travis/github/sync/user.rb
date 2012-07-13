require 'core_ext/module/include'

module Travis
  module Github
    module Sync
      class User
        attr_reader :user

        def initialize(user)
          @user = user
        end

        def run
          Organizations.new(user).run
          Repositories.new(user).run
        end
      end
    end
  end
end
