require 'colorize'
require 'sqlite3'


def determine_year content
  # can be double digit (00-09)
  # or 4 digits (2000-2009)
  # and optionally preceded by "MY" (model year)
  # ignore 1999

  /\b((my)?(20)?0\d)\b/i.match(content)[1] rescue nil
end

def determine_price content
  # look for full number,
  # or number followed by k
  # look for key words

  /(\$\s*[\d,\.]{1,6}k?)\b |
   (?:price|cost|paid)\s*\:?\s*\$?\s*([\d,\.]{1,6}k?)\b
  /ix.match(content).captures.compact[0] rescue nil
end

def determine_miles content
  /\b(\d[\d,\.x]{1,6}k?)\s*(?:mi|miles?|mileage) |
   (?:mi|miles?|mileage)\s*\:?\s*(\d[\d,\.x]{1,6}k?)\b
  /ix.match(content).captures.compact[0] rescue nil
end

$bad = 0
$good = 0
$filtered = 0

# [year, price, mileage]
def parse_content content
  # objective: get
  #   purchase date
  #   location
  #   CR?
  #   color
  #   notes

  year    = nil
  price   = nil
  mileage = nil
  color   = nil

  # puts content.black

  year = determine_year content
  content.sub!(year, '') if year

  price = determine_price content
  content.sub!(price, '') if price

  mileage = determine_miles content
  content.sub!(mileage, '') if mileage

  if year && price && mileage
    # puts "#{year.cyan} #{price.green} #{mileage.magenta}"
    $good += 1
    [year, price, mileage]
  else
    # puts content.yellow
    $bad += 1
    nil
  end
end

# filters

def not_enough_numbers content
  content.scan(/\d/).count < 6
end

def too_many_questions content
  content.scan(/\? |\?$/).count > 1
end

def is_trade content
  content.include? 'trade'
end


# postprocessing

def postprocess_year year
  year.sub!(/my/i, '')
  year.sub!(/^(\d{2})$/, '20\1')
  year
end


db = SQLite3::Database.new 's2ki.db'
rows = db.execute('SELECT * FROM forum')

# filter entire rows out
rows.reject! do |*, content|
  should_reject = not_enough_numbers(content) || too_many_questions(content) || is_trade(content)
  $filtered += 1 if should_reject

  should_reject
end

# cleanup content, remove noise
rows.map! do |*_, content|
  content.gsub!(/s2000|s2k/i, '')

  [*_, content]
end

# extract data from rows
rows.each do |row|
  username, published, location, content = row

  year, price, mileage = parse_content(content)
  next unless (year && price && mileage)

  year = postprocess_year year
  # price = postprocess_price price
  # mileage = postprocess_mileage mileage

  puts "#{year.cyan}"
end


puts "Filtered #{$filtered} rows"
puts "#{$good} / #{$good + $bad} parseable rows"
