CITIES_DEBUGGING = (::Rails.env == 'development')

def cities_debug(s)
  if CITIES_DEBUGGING
    puts s
  end
end

require 'citiesforrails/core_ext' 
require 'citiesforrails/acts_as_cities'