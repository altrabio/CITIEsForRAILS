#------------------------------------------------------------------------------------------------#
#                                                                                                #
#       Modifications for SQL Adapters : needed to take views into account                       #
#       (only SQLite, PostGreSQL & MySQL have been considered)                                   #
#                                                                                                #
#------------------------------------------------------------------------------------------------#

# SQLite

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


# PostGreSQL
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



# MySQL
# No Modification needed, this essentially comes from the fact that MySQL "show" command
# lists simultaneously tables & views
