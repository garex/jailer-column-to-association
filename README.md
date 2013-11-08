# Jailer associations generator

## Description

Auto-generates association.csv from column.csv when we have same column names.
It's useful in case of mysql MyISAM tables or another cases, when we lost our relationships.
Helper for http://jailer.sourceforge.net/ -- Java written database subsetting tool.

## Install

    wget https://raw.github.com/garex/jailer-column-to-association/master/jailer-column-to-association.rb
    chmod +x jailer-column-to-association.rb

## Usage

    path/to/jailer-column-to-association.rb path/to/yours/column.csv > path/to/yours/association.csv

## Requirements

Ruby at least 1.8.7 with csv module

## Copyright

(c) 2013 github.com/garex, a@ustimen.co

## GOODTODO

* Pack as a gem?
* More rubify: requirements
* Extend to another cases

