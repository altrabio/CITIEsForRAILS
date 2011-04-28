#Needed to allow additonal module 'requires'
path = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

# Methods which will be used by the class
require 'class_methods'

# Methods that will be used for the instances of the Non Root Classes
require 'instance_methods'

# Methods that will be used for the instances of the Non Root Classes
require 'child_instance_methods'

# Methods that will be used for the instances of the Root Classes
require 'root_instance_methods'

module Citier
  def self.included(base) 
    # When a class includes a module the module’s self.included method will be invoked.
    base.send :extend, ClassMethods
  end
end

ActiveRecord::Base.send :include, Citier
