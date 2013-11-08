#!/usr/bin/env ruby

require 'csv'

class Column

	attr_reader :name, :type

	@@re_fk = /_?id$/i

	def initialize(name, type)
		@name  = name
		@type  = type
	end
	
	def self.parse(line)
		arr = line.split(' ')
		self.new(arr[0], arr[1])
	end
	
	def is_pk_of(table_name)
		name  = @name.downcase.gsub('_', '')
		table = table_name.downcase.gsub('_', '')
		
		'id' == name || table + 'id' == name
	end
	
	def is_fk
		nil != (@name =~ @@re_fk)
	end
	
	def foreign_table_name
		@name.sub(@@re_fk, '')
	end

end

class Table
	
	attr_reader :name, :columns, :pk
	
	def initialize(name)
		@name    = name
		@columns = {}
	end
	
	def add_column(column)
		@columns[column.name] = column
		if column.is_pk_of(@name)
			@pk = column
		end
	end
	
	def self.parse(line)
		me = self.new(line.shift)
		line.compact.each {|r| me.add_column(Column.parse(r)) }
		me
	end
	
end

class Database

	attr_reader :tables
	
	def initialize()
		@tables = {}
	end

	def add_table(table)
		@tables[table.name] = table
	end
	
	def self.parse_from_csv(csv)
		csv.shift
		me = self.new
		csv.each {|l| me.add_table(Table.parse(l)) }
		me
	end
	
	def each_columns
		tables.sort.each {|t_key, t|
			t.columns.sort.each {|c_key, c|
				yield c, t
			}
		}
	end

end

def main
	usage if is_input_empty?

	db  = Database.parse_from_csv(CSV.parse(ARGF.read, '; '))

	associations = []
	db.each_columns {|c, t|
		next unless db.tables.has_key?(c.foreign_table_name)
		next if c == t.pk
		next unless c.is_fk
		
		f = db.tables[c.foreign_table_name]
		
		associations.push [
			t.name, c.foreign_table_name, 'B', 'n:1',
			'A.' + c.name + '=B.' + f.pk.name,
			'FK_' + t.name + '_' + c.foreign_table_name,
			'Associations generator', nil, nil
		]
	}
	
	CSV::Writer.generate($stdout, '; ') do |csv|
		associations.each do |a|
			csv << a
		end
	end

end

def is_input_empty?
	ARGV.empty? && STDIN.tty?
end

def usage
	$stderr.puts [
		'Auto-generates association.csv from column.csv when we have same column names.',
		'It`s useful in case of mysql MyISAM tables or another cases, when we lost our relationships.',
		'Helper for http://jailer.sourceforge.net/ -- Java written database subsetting tool.',
		'',
		'     (c) 2013 github.com/garex, a@ustimen.co',
		'',
		'',
		"Usage: #{File.basename($0)} path/to/yours/column.csv > path/to/yours/association.csv",
	] * $/
	exit
end

main

