#!/usr/bin/env ruby

require 'rubygems'
require 'slop'

opts = Slop.new({
	:help   => true,
	:banner =>	[
		'Auto-generates association.csv from column.csv when we have same column names.',
		'It`s useful in case of mysql MyISAM tables or another cases, when we lost our relationships.',
		'Helper for http://jailer.sourceforge.net/ -- Java written database subsetting tool.',
		'',
		'     (c) 2013 github.com/garex, a@ustimen.co',
		'',
		'',
		"Usage: #{File.basename($0, '.*')} [options]",
	] * $/
	}) do
  on :s, :source=,      'Source column CSV file. Usually "column.csv"', {:required => true}
  on :d, :destination=, 'Destination associations CSV file. Usually "association.csv"', {:required => true}
end

begin
	opts.parse! ARGV
rescue Slop::MissingOptionError => err
	$stderr.puts err
	$stderr.puts '*' * 50
	$stderr.puts opts.help
	exit
end

p opts.to_hash

