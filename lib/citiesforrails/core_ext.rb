




#------------------------------------------------------------------------------------------------#
#                                                                                                #
#       Modifications for ActiveRecord                                                           #
#                                                                                                #
#------------------------------------------------------------------------------------------------#

class ActiveRecord::Base  

  def reload 
    self.class.find(self.id)
  end

  def self.[](column_name) 
    arel_table[column_name]
  end

  def swap_new_record # a new own method to arbitrary change the value of the @persisted instance variable
    # (this instance variable is a flag which indicates if a record is a new one or not)
    @persisted=!@persisted
    puts "not persisted"
  end


  def self.create_class_part_of(class_reference)  #creation of a new class which inherits from ActiveRecord::Base

    def class_reference.has_a_part_of?
      return true
    end

    Class.new(ActiveRecord::Base) do
      a=class_reference.table_name
      b=a[5..a.length]
      set_table_name(b)#set the name of the table associated to this class
      # this class will be associated to the write table of the class_reference class
      # consequently the name of the table is the name of the read table without "view_" 

    end     
  end


end








#------------------------------------------------------------------------------------------------#
#                                                                                                #
#       Modifications for ActiveRecord::Persistence                                              #
#                                                                                                #
#------------------------------------------------------------------------------------------------#

module ActiveRecord

  module Persistence

    def destroy

      if persisted?     
        if (self.class.respond_to?("mother_class"))&&(self.class.table_name[0]=="v" && self.class.table_name[1]=="i" && self.class.table_name[2]=="e" && self.class.table_name[3]=="w" && self.class.table_name[4]=="_")
          #if the class of the object is based on this gem and if the considered table is a view
          puts"modified version of ActiveRecord::Persistence destroy"       
          puts "class = #{self.class.name} table name=#{self.class.table_name} this is a view : skipping some instructions"
        else
          puts"unmodified version of ActiveRecord::Persistence destroy"       
          self.class.unscoped.where(self.class.arel_table[self.class.primary_key].eq(id)).delete_all
        end
      end

      @destroyed = true

      freeze
    end
  end
end





#-----------------------------------------------------------------------------------------------#
#                                                                                               #
#       Some functions to manage views creation & dropping                                        #
#                                                                                               #
#-----------------------------------------------------------------------------------------------#
def CreateTheViewForCITIEs(theclass)  #function for creating views for migrations 

  if RAILS_ENV == 'development'
    puts "CreateTheView 1"
  end
  self_columns = theclass::PartOf.column_names.select{ |c| c != "id" } 
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
  self_write_table = theclass::PartOf.table_name
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

def DropTheViewForCITIEs(theclass) #function for dropping views for migrations 
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


#------------------------------------------------------------------------------------------------#
#                                                                                                #
#       Modifications for SQL Adapters : needed to take views into account                       #
#       (only SQLite, PostGreSQL & MySQL has been considered)                                    #
#                                                                                                #
#------------------------------------------------------------------------------------------------#


#------------------------------------------------------------------------------------------------#
#       Modifications for SQL Adapters : SQLite                                                  #
#------------------------------------------------------------------------------------------------#
require 'active_record'
require 'active_record/connection_adapters/sqlite_adapter'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'active_record/connection_adapters/postgresql_adapter'
module ActiveRecord
  module ConnectionAdapters
    class SQLiteAdapter < AbstractAdapter

      def tables(name = nil) 
        sql = <<-SQL
        SELECT name
        FROM sqlite_master
        WHERE (type = 'table' or type='view') AND NOT name = 'sqlite_sequence'
        SQL
        # Modification : the where clause was intially WHERE type = 'table' AND NOT name = 'sqlite_sequence' 
        #                now it is WHERE (type = 'table' or type='view') AND NOT name = 'sqlite_sequence'
        # this modification is made to consider tables AND VIEWS as tables

        execute(sql, name).map do |row|
          row['name']
        end
      end
    end
  end

end


#------------------------------------------------------------------------------------------------#
#       Modifications for SQL Adapters : PostGreSQL                                              #
#------------------------------------------------------------------------------------------------#


module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      def tables(name = nil)
        a=tablesL(name)
        puts("1------>#{a}")        
        b=viewsL(name)
        if(b!=[])
          a=a+b
        end
        puts("2------>#{a}")
        return a
      end

      def tablesL(name = nil)

        query(<<-SQL, name).map { |row| row[0] }
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = ANY (current_schemas(false))
        SQL
      end
      def viewsL(name = nil)

        query(<<-SQL, name).map { |row| row[0] }
        SELECT viewname
        FROM pg_views
        WHERE schemaname = ANY (current_schemas(false))
        SQL
      end

      def table_exists?(name)
        a=table_existsB?(name)
        b=views_existsB?(name)
        puts"T---->#{a}"
        puts"T---->#{b}"
        return a||b
      end


      def table_existsB?(name)
        name          = name.to_s
        schema, table = name.split('.', 2)

        unless table # A table was provided without a schema
          table  = schema
          schema = nil
        end

        if name =~ /^"/ # Handle quoted table names
          table  = name
          schema = nil
        end

        query(<<-SQL).first[0].to_i > 0
        SELECT COUNT(*)
        FROM pg_tables
        WHERE tablename = '#{table.gsub(/(^"|"$)/,'')}'
        #{schema ? "AND schemaname = '#{schema}'" : ''}
        SQL

      end
      def views_existsB?(name)
        name          = name.to_s
        schema, table = name.split('.', 2)

        unless table # A table was provided without a schema
          table  = schema
          schema = nil
        end

        if name =~ /^"/ # Handle quoted table names
          table  = name
          schema = nil
        end

        query(<<-SQL).first[0].to_i > 0
        SELECT COUNT(*)
        FROM pg_views
        WHERE viewname = '#{table.gsub(/(^"|"$)/,'')}'
        #{schema ? "AND schemaname = '#{schema}'" : ''}
        SQL

      end
    end
  end
end



#------------------------------------------------------------------------------------------------#
#       Modifications for SQL Adapters : MySQL                                                   #
#------------------------------------------------------------------------------------------------#

# No Modification needed, this essentially comes from the fact that MySQL "show" command
# lists simultaneously tables & views





#               -------------------------------------------------------------                     #
