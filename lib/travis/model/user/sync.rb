require 'core_ext/module/include'

class User
  class Sync
    include do
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def run
        Metriks.timer('user.sync').time do
          Organization.sync_for(user)
          Repository.sync_for(user)
        end
      end
    end
  end
end
