# frozen_string_literal: true

require 'English'
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
    new(arr[0], arr[1])
  end

  def is_pk_of(table_name)
    name  = @name.downcase.gsub('_', '')
    table = table_name.downcase.gsub('_', '')

    ['id', "#{table}id"].include?(name)
  end

  def is_fk
    (@name =~ @@re_fk) != nil
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
    @pk = column if column.is_pk_of(@name)
  end

  def self.parse(line)
    me = new(line.shift)
    line.compact.each { |r| me.add_column(Column.parse(r)) }
    me
  end
end

class Database
  attr_reader :tables

  def initialize
    @tables = {}
  end

  def add_table(table)
    @tables[table.name] = table
  end

  def self.parse_from_csv(csv)
    csv.shift
    me = new
    csv.each { |l| me.add_table(Table.parse(l)) }
    me
  end

  def each_columns
    tables.sort.each do |_t_key, t|
      t.columns.sort.each do |_c_key, c|
        yield c, t
      end
    end
  end
end

def main
  usage if input_empty?

  db = Database.parse_from_csv(CSV.parse(ARGF.read, col_sep: '; ', liberal_parsing: true))

  associations = []
  db.each_columns do |c, t|
    next unless db.tables.key?(c.foreign_table_name)
    next if c == t.pk
    next unless c.is_fk

    f = db.tables[c.foreign_table_name]

    associations.push [
      t.name, c.foreign_table_name, 'B', 'n:1',
      "A.#{c.name}=B.#{f.pk.name}",
      "FK_#{t.name}_#{c.foreign_table_name}",
      'Associations generator', nil, nil
    ]
  end

  str = CSV.generate(col_sep: '; ', quote_char: '') do |csv|
    associations.each do |row|
      csv << row
    end
  end

  puts str
end

def input_empty?
  ARGV.empty? && $stdin.tty?
end

def usage
  warn [
    'Auto-generates association.csv from column.csv when we have same column names.',
    'It`s useful in case of mysql MyISAM tables or another cases, when we lost our relationships.',
    'Helper for http://jailer.sourceforge.net/ -- Java written database subsetting tool.',
    '',
    '     (c) 2013 github.com/garex, a@ustimen.co',
    '',
    '',
    "Usage: #{File.basename($PROGRAM_NAME)} path/to/yours/column.csv > path/to/yours/association.csv"
  ] * $INPUT_RECORD_SEPARATOR
  exit
end

main
