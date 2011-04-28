module InstanceMethods

  # Delete the model (and all parents it inherits from if applicable)
  def delete
    cities_debug("Deleting #{self.class.to_s} with ID #{self.id}")
    # Delete information stored in the table associated to the class of the object
    # (if there is such a table)
    deleted = true
    deleted &= self.class::Clone.delete(self.id)
    if(self.class.superclass!=ActiveRecord::Base)
      # Delete up the hierarchy
      deleted &= self.class.superclass.delete(self.id)
    end
    
    return deleted
  end

  def updatetype        
    sql = "UPDATE #{self.class.mother_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
    self.connection.execute(sql)
    puts"#{sql}"      
  end

  def destroy
    super
    if self.class.respond_to?('has_a_part_of?')
      qdestroy
    else
      return self
    end
  end

  def qdestroy
    xxx=self.class
    qqq=xxx

    while xxx!=ActiveRecord::Base do

      if xxx.respond_to?('has_a_part_of?') # eventually delete pieces of information stored in the write tables associated to the current xxx class for the object (if there is such a table)

        if (xxx.superclass==xxx.mother_class || xxx::Clone!=xxx.superclass::Clone)

          puts "partof for class = #{xxx.name}"
          xxx::Clone.destroy(self.id)
          #oo=xxx::Clone.find(self.id)
          #oo.destroy

        else           
          puts "no part of for class = #{xxx.name}"                 
        end#partof
      end #respond

      qqq=xxx
      xxx=xxx.superclass

    end #while

    puts "#{qqq.name} should be the mother class"          
    qqq.delete(self.id) #delete information into the table of the mother class

    return self
  end

end