# Backport some ruby-1.9 features to ruby-1.8

module Kernel
  def singleton_class
    (class << self; self; end)
  end unless method_defined?(:singleton_class)

  def spawn(*args)
    args.reject! { |item| item.instance_of? Hash }
    Kernel.fork { Kernel.exec(*args) }
  end unless method_defined?(:spawn)
end

class Class
  def define_singleton_method(*args, &proc)
    singleton_class.module_eval { define_method(*args, &proc) }
  end unless method_defined?(:define_singleton_method)
end
