require 'travis/features'
require 'travis/services/base'

module Travis
  module Services
    class FindAdmin < Base
      class Cache < Struct.new(:repo, :params)
        def lookup
          admin = find_admin if active?
          return admin if admin
          admin = yield
          store_admin(admin) if active?
          admin
        end

        private

          def active?
            params[:cache] && Travis::Features.enabled_for_all?(:allow_cache_admin)
          end

          def find_admin
            id = Travis.redis.get(key)
            User.find(id) if id
          end

          def store_admin(admin)
            Travis.redis.set(key, admin.id) if admin
          end

          def key
            "repository:admin:#{repo.id}"
          end
      end
    end
  end
end
