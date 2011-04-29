module ChildInstanceMethods

  def save

    #get the attributes of the class which are inherited from it's parent.
    attributes_for_parent = self.attributes.reject{|key,value| !self.class.superclass.column_names.include?(key) }

    # Get the attributes of the class which are unique to this class and not inherited.
    attributes_for_current = self.attributes.reject{|key,value| self.class.superclass.column_names.include?(key) }

    citier_debug("Attributes for #{self.class.to_s}: #{attributes_for_current.inspect.to_s}")

    #create a new instance of the superclass, passing the inherited attributes.
    parent = self.class.superclass.new(attributes_for_parent)
    parent.id = self.id

    parent.is_new_record(new_record?)

    parent_saved = parent.save
    self.id = parent.id

    if(parent_saved==false)
      # Couldn't save parent class
      # TODO: Handle situation where parent class could not be saved
      citier_debug("Class (#{self.class.superclass.to_s}) could not be saved")
    end

    # If there are attributes for the current class (unique & not inherited) 
    # and parent(s) saved successfully, save current model
    if(!attributes_for_current.empty? && parent_saved)
      current = self.class::Writable.new(attributes_for_current)
      current.is_new_record(new_record?)
      current_saved = current.save
      
      # This is no longer a new record
      is_new_record(false)

      if(!current_saved)
        citier_debug("Class (#{self.class.superclass.to_s}) could not be saved")
      end
    end

    # Update root class with this 'type'
    sql = "UPDATE #{self.class.root_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
    citier_debug("SQL : #{sql}")
    self.connection.execute(sql)
    return parent_saved && current_saved
  end

  include InstanceMethods
end