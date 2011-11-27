class Repository
  module ServiceHook
    def service_hook
      @service_hook ||= ::ServiceHook.new(
        :owner_name => owner_name,
        :name => name,
        :active => active,
        :repository => self
      )
    end
  end
end
