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

      self.const_set("Clone", create_class_clone(self)) # it will stand for the write table of the current class            

      send :include, ChildInstanceMethods
    else
      #------------------------------------------------------------------------------------------------------------------------ 
      #
      #             methods that will be used for the mother class
      #
      #------------------------------------------------------------------------------------------------------------------------
      after_save :updatetype

      cities_debug("acts_as_cities -> MOTHER class")
      puts("now table_name->#{table_name}")
      set_table_name "#{table_name}"     
      puts "tablename->#{self.table_name}"

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
      send :include, MotherInstanceMethods
    end



  end

end  