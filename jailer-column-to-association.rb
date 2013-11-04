#!/usr/bin/env ruby

def main(argv)
	usage if argv.empty?
	
	p argv
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
		"Usage: #{File.basename($0)} path-to-column.csv",
	] * $/
	exit
end


main ARGV

