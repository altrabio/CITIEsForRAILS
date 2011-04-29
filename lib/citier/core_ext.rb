class ActiveRecord::Base  

  def self.[](column_name) 
    arel_table[column_name]
  end

  def is_new_record(state)
    @new_record = state
  end
  
  def self.all(*args)
    # For some reason need to override this so it uses my modified find function which reloads each object to pull in all properties.
    return find(:all, *args)
  end

  def self.create_class_writable(class_reference)  #creation of a new class which inherits from ActiveRecord::Base
    Class.new(ActiveRecord::Base) do
      t_name = class_reference.table_name
      t_name = t_name[5..t_name.length]

      if t_name[0..5] == "view_"
        t_name = t_name[5..t_name.length]
      end

      # set the name of the table associated to this class
      # this class will be associated to the writable table of the class_reference class
      set_table_name(t_name)
    end
  end
end

def create_citier_view(theclass)  #function for creating views for migrations 
  self_columns = theclass::Writable.column_names.select{ |c| c != "id" }
  parent_columns = theclass.superclass.column_names.select{ |c| c != "id" }
  columns = parent_columns+self_columns
  self_read_table = theclass.table_name
  self_write_table = theclass::Writable.table_name
  parent_read_table = theclass.superclass.table_name
  sql = "CREATE VIEW #{self_read_table} AS SELECT #{parent_read_table}.id, #{columns.join(',')} FROM #{parent_read_table}, #{self_write_table} WHERE #{parent_read_table}.id = #{self_write_table}.id" 
  citier_debug("Creating citier view -> #{sql}")
  theclass.connection.execute sql
end

def drop_citier_view(theclass) #function for dropping views for migrations 
  self_read_table = theclass.table_name
  sql = "DROP VIEW #{self_read_table}"
  citier_debug("Dropping citier view -> #{sql}")
  theclass.connection.execute sql
end