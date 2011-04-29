CITIER_DEBUGGING = (::Rails.env == 'development')

def citier_debug(s)
  if CITIER_DEBUGGING
    puts "citier -> " + s
  end
end

require 'citier/core_ext'

# Methods which will be used by the class
require 'citier/class_methods'

# Methods that will be used for the instances of the Non Root Classes
require 'citier/instance_methods'

# Methods that will be used for the instances of the Root Classes
require 'citier/root_instance_methods'

# Methods that will be used for the instances of the Non Root Classes
require 'citier/child_instance_methods'

# Require SQL Adapters
require 'citier/sql_adapters'

#Require acts_as_citier hook
require 'citier/acts_as_citier'