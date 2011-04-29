#Needed to allow additonal module 'requires'
path = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'sql_adapters'

class ActiveRecord::Base  

  def self.[](column_name) 
    arel_table[column_name]
  end
  
  def is_new_record(state)
    @new_record = state
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

  if RAILS_ENV == 'development'
    puts "CreateTheView 1"
  end
  self_columns = theclass::Writable.column_names.select{ |c| c != "id" } 
  if RAILS_ENV == 'development' 
    puts "CreateTheView 2"
  end
  parent_columns = theclass.superclass.column_names.select{ |c| c != "id" }
  columns = parent_columns+self_columns
  if RAILS_ENV == 'development' 
    puts "CreateTheView 3"
  end
  self_read_table = theclass.table_name
  # eventuellement warning si pas de part_of
  self_write_table = theclass::Writable.table_name
  parent_read_table = theclass.superclass.table_name
  if RAILS_ENV == 'development' 
    puts "CreateTheView 4"
  end

  if RAILS_ENV == 'development' 
    puts " self read table #{self_read_table} | parent_read_table #{parent_read_table}"
  end
  sql = "CREATE VIEW #{self_read_table} AS SELECT #{parent_read_table}.id, #{columns.join(',')} FROM #{parent_read_table}, #{self_write_table} WHERE #{parent_read_table}.id = #{self_write_table}.id" 
  theclass.connection.execute sql
end

def drop_citier_view(theclass) #function for dropping views for migrations 
  if RAILS_ENV == 'development'
    puts "1 DropTheViewForCITIEs"
  end
  self_read_table = theclass.table_name

  if RAILS_ENV == 'development' 
    puts " DROP VIEW #{self_read_table}"
  end
  sql = "DROP VIEW #{self_read_table}" 
  theclass.connection.execute sql
end