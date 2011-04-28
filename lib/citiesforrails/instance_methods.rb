module InstanceMethods

  # Delete the model (and all parents it inherits from if applicable)
  def delete(id = self.id)
    cities_debug("Deleting #{self.class.to_s} with ID #{self.id}")
    
    # Delete information stored in the table associated to the class of the object
    # (if there is such a table)
    deleted = true
    if(self.class.superclass!=ActiveRecord::Base)
      cities_debug("Deleting self")
      deleted &= self.class::Clone.delete(id)
      cities_debug("Deleting back up hierarchy")
      deleted &= self.class.superclass::Clone.delete(id)
    else
      deleted &= self.class.delete(id)
    end

    return deleted
  end

  def updatetype        
    sql = "UPDATE #{self.class.mother_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
    self.connection.execute(sql)
    cities_debug("#{sql}")
  end

  def destroy
    return self.delete
  end

end