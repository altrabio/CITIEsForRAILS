module InstanceMethods

  # Delete the model (and all parents it inherits from if applicable)
  def delete
    cities_debug("Deleting #{self.class.to_s} with ID #{self.id}")
    
    # Delete information stored in the table associated to the class of the object
    # (if there is such a table)
    deleted = true
    if(self.class.superclass!=ActiveRecord::Base)
      # Delete up the hierarchy
      deleted &= self.class::Clone.delete(self.id)
      deleted &= self.class.superclass.delete(self.id)
    else
      deleted &= self.class.delete(self.id)
    end

    return deleted
  end

  def updatetype        
    sql = "UPDATE #{self.class.mother_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
    self.connection.execute(sql)
    puts"#{sql}"      
  end

  def destroy
    return self.delete
  end

end