require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    attr_accessor

    def self.table_name
        self.to_s.downcase.pluralize
    end
  
    def self.column_names
        sql = "PRAGMA table_info('#{table_name}')"
        
        table_info = DB[:conn].execute(sql)
        column_names = []

        table_info.each do |column|
            column_names << column["name"]
        end
        column_names.compact
    end

        self.column_names.each do |col_name|
          attr_accessor col_name.to_sym
        end
   
    def initialize(attributes = {})
        attributes.each do |property, value|
            self.send("#{property}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if{|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
        
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", [name])
    end

    def self.find_by(values_for_insert)
         binding.pry
        
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{values_for_insert} = ?", [values_for_insert])
        DB[:conn].execute(“SELECT * FROM #{self.table_name} WHERE #{values_for_insert} = ?”, [values_for_insert])
    end
end