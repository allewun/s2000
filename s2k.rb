#!/usr/bin/env ruby

require 'colorize'
require_relative 'helpers/analyze.rb'
require_relative 'helpers/extract.rb'
require_relative 'helpers/scrape.rb'


DATABASE_FILE = 's2k.db'
FORUM_URL     = 'http://www.s2ki.com/s2000/topic/903878-how-much-did-you-pay-for-your-used-s2000/'


puts "Starting " + "S2000".white + " data collection..."

# scrape if desired
if File.exist?(DATABASE_FILE)
  print "Database already exists. Scrape again? [y/n] "
  if gets.chomp == 'y'
    File.delete DATABASE_FILE
    db = SQLite3::Database.new DATABASE_FILE
    db.execute <<-SQL
      CREATE TABLE forum (
        username  TEXT,
        published TEXT,
        location  TEXT,
        content   TEXT UNIQUE
      );
    SQL

    # scrape
    puts
    puts "Scraping..."
    scrape
  end
end

# extract
puts
puts "Extracting data..."
data = extract

# analyze
puts
puts "Generating plots..."
analyze data
