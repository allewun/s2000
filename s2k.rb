#!/usr/bin/env ruby

require 'colorize'
require_relative 'helpers/analyze.rb'
require_relative 'helpers/extract.rb'
require_relative 'helpers/scrape.rb'

RESULTS_DIR   = 'results'
DATABASE_FILE = "#{RESULTS_DIR}/s2k.db"
FORUM_URL     = 'http://www.s2ki.com/s2000/topic/903878-how-much-did-you-pay-for-your-used-s2000/'


puts "Starting " + "S2000".white + " data collection..."

# scrape if desired
should_scrape =
  if File.exist? DATABASE_FILE
    print "Database already exists. Scrape again? [y/n] "
    gets.chomp == 'y'
  else
    true
  end

if should_scrape
  setup_db

  puts
  puts "Scraping..."
  scrape
end

# extract
puts
puts "Extracting data..."
data = extract

# analyze
puts
puts "Generating plots..."
analyze data

save_data data
