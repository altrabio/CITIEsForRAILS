module Citier
  def self.included(base) 
    # When a class includes a module the module’s self.included method will be invoked.
    base.send :extend, ClassMethods
  end
end

ActiveRecord::Base.send :include, Citier
