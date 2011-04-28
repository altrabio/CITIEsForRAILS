CITIER_DEBUGGING = (::Rails.env == 'development')

def citier_debug(s)
  if CITIER_DEBUGGING
    puts "citierforrails -> " + s
  end
end

require 'citier/core_ext' 
require 'citier/acts_as_citier'