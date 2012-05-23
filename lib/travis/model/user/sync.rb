class User
  class Sync
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def run
      Organization.sync_for(user)
      Repository.sync_for(user)
    end
  end
end
