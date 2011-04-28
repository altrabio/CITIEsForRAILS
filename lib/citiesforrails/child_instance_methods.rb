module ChildInstanceMethods

  def save

    if(self.class.superclass==ActiveRecord::Base)
      #This is the highest class you can get to, just save the model
      cities_debug("Mother Class #{self.class.to_s}")
      return self.class.save
    else
      # Non mother class, continue with saving parent etc
      cities_debug("Non-Mother Class #{self.class.to_s}")
    end

    #get the attributes of the class which are inherited from it's parent.
    attributes_for_parent = self.attributes.reject{|key,value| !self.class.superclass.column_names.include?(key) }

    # Get the attributes of the class which are unique to this class and not inherited.
    attributes_for_current = self.attributes.reject{|key,value| self.class.superclass.column_names.include?(key) }

    #create a new instance of the superclass, passing the inherited attributes.
    parent = self.class.superclass.new(attributes_for_parent)

    if(!new_record?)
      parent.swap_new_record
      parent.id = self.id
    end

    if(parent.class==parent.class.mother_class)
      # save the new parent instance (by calling its save method) 
      parent_saved = parent.save
    end

    if(parent_saved==false)
      # Couldn't save parent class
      # TODO: Handle if parent class could not be saved
      cities_debug("Class (#{self.class.superclass.to_s}) could not be saved")
    end

    # If there are attributes for the current class (unique & not inherited) 
    # and parent(s) saved successfully, save current model
    if(!attributes_for_current.empty? && parent_saved)
      current = self.class::PartOf.new(attributes_for_current) 
      current.id = parent.id

      if(!new_record?)
        current.swap_new_record
      end

      current_saved = current.save
      if(current_saved==false)
        cities_debug("Class (#{self.class.superclass.to_s}) could not be saved")
      end
    end

    self.id = parent.id

    sql = "UPDATE #{self.class.mother_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
    cities_debug("SQL : #{sql}")
    self.connection.execute(sql)
    return parent_saved && current_saved
  end

  #call the class delete method with the id of the instance
  def delete
    cities_debug("1-> Delete #{self.class.name} with ID #{self.id}")
    self.class.delete(self.id)
  end


end