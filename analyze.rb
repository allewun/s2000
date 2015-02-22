require 'colorize'
require 'sqlite3'

require_relative 'helpers/extract.rb'
require_relative 'helpers/filter.rb'
require_relative 'helpers/postprocess.rb'

$bad = 0
$good = 0
$filtered = 0


db = SQLite3::Database.new 's2ki.db'
rows = db.execute('SELECT * FROM forum')

# filter entire rows out
rows.reject! do |*, content|
  should_reject = not_enough_numbers(content) ||
                  too_many_questions(content) ||
                  is_trade(content) ||
                  is_international(content)

  $filtered += 1 if should_reject

  should_reject
end

# cleanup content, remove noise
rows.map! do |*_, content|
  content.gsub!(/s2000|s2k/i, '')

  [*_, content]
end

# extract data from rows
puts "YEAR".cyan + "\t" + "PRICE".green + "\t" + "MILEAGE".red
rows.each do |row|
  username, published, location, content = row

  year, price, mileage = extract_content(content)
  next unless (year && price && mileage)

  year    = postprocess_year year
  price   = postprocess_price price
  mileage = postprocess_mileage mileage

  puts "#{year.to_s.cyan}\t#{price.to_s.green}\t#{mileage.to_s.red}"
end


puts "Filtered #{$filtered} rows"
puts "#{$good} / #{$good + $bad} parseable rows"
