module Cities
  
  def self.included(base) 
    #When a class includes a module the module’s self.included method will be invoked.
    base.send :extend, ClassMethods
  end

 
#------------------------------------------------------------------------------------------------------------------------ 
#
#             methods that will be used for the class
#
#------------------------------------------------------------------------------------------------------------------------

  module ClassMethods
    # any method placed here will apply to classes
    

    def acts_as_cities(options = {}) #options hash see below
        
        
        db_type_field = (options[:db_type_field] || :type).to_s         #:db_type_field = option for setting the inheritance columns, default value = 'type'
        puts "tablename option->#{:table_name}"
        table_name = (options[:table_name] || self.name.tableize.gsub(/\//,'_')).to_s  #:table_name = option for setting the name of the current class table_name, default value = 'tableized(current class name)'
        puts "tablename now->#{table_name}"

        set_inheritance_column "#{db_type_field}"

        if(self.superclass!=ActiveRecord::Base)
          #------------------------------------------------------------------------------------------------------------------------ 
          #
          #             methods that will be used for the NON mother class
          #
          #------------------------------------------------------------------------------------------------------------------------
          puts "acts_as_cities -> NON mother class"
    
          set_table_name "view_#{table_name}"
          puts "tablename->#{self.table_name}"
          aaa=create_class_part_of self# these 2 lines are there for the creation of class PartOf (which is a class of the current class)
          self.const_set("PartOf",aaa) # it will stand for the write table of the current class            
          
          
          
           def self.delete(id) #overrides delete to delete every pieces of information about this record wherever it may be stored
              if RAILS_ENV == 'development' 
                puts "delete de classe = #{self.name}"
              end
              return self.delete(id) if self == self.mother_class #if the class of the record is the mother class then call with the id of the object
                                                                #if the class of the record is not the mother class then 
              if RAILS_ENV == 'development' 
                puts "2->delete de classe = #{self.name}"
              end

              if self.respond_to?('has_a_part_of?') # eventually delete pieces of information stored in the table associated to the class of the object (if there is such a table)
                if self.has_a_part_of?  && (self.superclass==self.mother_class || self::PartOf!=self.superclass::PartOf) #SHOW TO LB implique moins de SQL
                  if RAILS_ENV == 'development' 
                    puts("has a part of")
                  end
                  self::PartOf.delete(id)
                else
                  if RAILS_ENV == 'development' 
                    puts "no part of" 
                  end
                end 
              end

              if RAILS_ENV == 'development' 
                puts "3->delete de classe = #{self.name}"
              end

              self.superclass.delete(id)                     # call the delete method associated to the super class of the current class with the id the object
           end  
            
          
              send :include, InstanceMethods1              
        else
          #------------------------------------------------------------------------------------------------------------------------ 
          #
          #             methods that will be used for the mother class
          #
          #------------------------------------------------------------------------------------------------------------------------
          after_save :updatetype
         
          
          if RAILS_ENV == 'development' 
            puts "acts_as_cities -> MOTHER class"        
          end
          puts("now table_name->#{table_name}")
          set_table_name "#{table_name}"     
          puts "tablename->#{self.table_name}"
          #table_name = (options[:table_name] || self.name.tableize.gsub(/\//,'_')).to_s  #:table_name = option for setting the name of the current class table_name, default value = 'tableized(current class name)'
          
          def self.mother_class #returns the mother class (the highest inherited class before ActiveRecord) 
           if(self.superclass!=ActiveRecord::Base)  
              self.superclass.mother_class
            else
            return self 
            end
          end 



          def self.find(*args) #overrides find to get more informations   
            
            tuples = super
            return tuples if tuples.kind_of?(Array) # in case of several tuples just return the tuples as they are
            #tuples.reload2                         # reload2 is defined in lib/activerecord_ext.rb
            tuples.class.where(tuples.class[:id].eq(tuples.id))[0]  # in case of only one tuple return a reloaded tuple  based on the class of this tuple
                                                                    # this imply a "full" load of the tuple
                                                                    # A VOIR AVEC LB peut être préfère t il laisser reload2                                                        
          end


          def self.delete_all #contrary to destroy_all this is useful to override this method : In fact destroy_all will explicitly call a destroy method on each object
                              #whereas delete_all doesn't and only call a specific SQL request
                              # (to be even more precise delete explictly call delete_all with special conditions )
            
            self.all.each{|o| o.delete } #call delete method for each instance of the class
            
          end
          
      
                   
          send :include, InstanceMethods
        end
        
        

    end
  
  end  
 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 
 
 
 
 
#------------------------------------------------------------------------------------------------------------------------
# 
#                 methods that will be used for the instances of the Non Mother Classes
#
#------------------------------------------------------------------------------------------------------------------------ 

    module InstanceMethods1
 
      def save #this gonna be used for the lowest level of hierarchy

    
        attributes_for_super = self.attributes.select{|key,value| self.class.superclass.column_names.include?(key) } #get the attributes of the class of the instance that also belong to its superclass 
        attributes_for_part_of = self.attributes.select{|key,value| !self.class.superclass.column_names.include?(key) } #get the attributes of the class of the instance that do not belong to its superclass
                                                                                                                        # these pieces of information should be stored in the table associated to the class of the instance
        herited = self.class.superclass.new(attributes_for_super)   #create a new instance of the superclass of the considered instance (self) 
        if(!new_record?)
            puts "S1"
            herited.swap_new_record
            herited.id = self.id
        end

        if(herited.class==herited.class.mother_class)
          herited_saved = herited.save # save the new instance (by calling its save method)      
        else
          herited_saved = herited.saveBis # save the new instance (by calling its save method)      
        end
    
        if(herited_saved==false) 
          puts('please contact us') # que faire si herited_saved vaut false ? A VOIR
        end

        part_of_saved=true
        if( ! attributes_for_part_of.empty? ) #if there are some pieces of information to save in the table associated to the class of the considered instance
          part_of = self.class::PartOf.new(attributes_for_part_of) 
          part_of.id = herited.id

          if(!new_record?)
            puts "S2"
            part_of.swap_new_record
          end

          part_of_saved = part_of.save
          if(part_of_saved==false) 
            puts('please contact us...') # que faire si herited_saved vaut false ? A VOIR
          end
         end


        self.id = herited.id
        
        if(new_record?)
          herited.swap_new_record;#this is very important for multi saving without reloading, if it was not there it would imply several savings in DB....
        end
        
        sql = "UPDATE #{self.class.mother_class.table_name} SET #{self.class.inheritance_column} = '#{self.class.to_s}' WHERE id = #{self.id}"
        if RAILS_ENV == 'development' 
          puts "SQL : #{sql}"
        end
        self.connection.execute(sql)
        return herited_saved && part_of_saved
      end



      def saveBis #this gonna be used for the intermediate level of hierarchy


        attributes_for_super = self.attributes.select{|key,value| self.class.superclass.column_names.include?(key) } #get the attributes of the class of the instance that also belong to its superclass 
        attributes_for_part_of = self.attributes.select{|key,value| !self.class.superclass.column_names.include?(key) } #get the attributes of the class of the instance that do not belong to its superclass
                                                                                                                        # these pieces of information should be stored in the table associated to the class of the instance
        herited = self.class.superclass.new(attributes_for_super)   #create a new instance of the superclass of the considered instance (self) 
        if(!new_record?)
            puts "S3"          
            herited.swap_new_record
            herited.id = self.id
        end


        if(herited.class==herited.class.mother_class)
            herited_saved = herited.save # save the new instance (by calling its save method)      
        else
            herited_saved = herited.saveBis # save the new instance (by calling its save method)      
        end

        if(herited_saved==false) 
          puts('please contact altrabio use the following mail : altrabio...altrabio.com') # que faire si herited_saved vaut false ? A VOIR
        end

        part_of_saved=true
        if( ! attributes_for_part_of.empty? ) #if there are some piecesof information to save in the table associated to the class of the cosidered instance
          part_of = self.class::PartOf.new(attributes_for_part_of) #
          part_of.id = herited.id

          if(!new_record?)
            puts "S4"            
            part_of.swap_new_record
          end

          part_of_saved = part_of.save
          if(part_of_saved==false) 
            puts('please contact altrabio use the following mail : altrabio...altrabio.com') # que faire si herited_saved vaut false ? A VOIR
          end
         end


        self.id = herited.id

        return herited_saved && part_of_saved
      end

      def delete   #call the class delete method with the id of the instance
         if RAILS_ENV == 'development' 
           puts("1-> delete d'instance #{self.id} la classe est #{self.class.name}")
         end
         self.class.delete( self.id)

         if RAILS_ENV == 'development' 
           puts("wl1")
         end
     end

    end
 
 
 
 
 
 
 
 
 
 
    #------------------------------------------------------------------------------------------------------------------------
    # 
    #                 methods that will be used for the instances of the Mother Class
    #
    #------------------------------------------------------------------------------------------------------------------------ 
 
    module InstanceMethods
 

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

              if (xxx.superclass==xxx.mother_class || xxx::PartOf!=xxx.superclass::PartOf)

                puts "partof for class = #{xxx.name}"
                xxx::PartOf.destroy(self.id)
                #oo=xxx::PartOf.find(self.id)
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
  
  
  
  
  
end  
  ActiveRecord::Base.send :include, Cities 
  

