class Module
  def prepend_to(name, &prepended)
    method = instance_method(name)
    include Module.new {
      define_method name do |*args, &block|
        method.bind(self).call(*args, &block)
      end
    }
    define_method(name, &prepended)
  end

  def __implementation__
    @__implementation__ ||=Module.new.tap { |mod| include(mod) }
  end
end
