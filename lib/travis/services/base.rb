module Travis
  module Services
    class Base
      include Travis::Services

      def initialize(dependencies = {})
        meta_class = (class << self; self; end)
        dependencies.each do |key, value|
          meta_class.send(:define_method, key) { value }
        end
      end
    end
  end
end
