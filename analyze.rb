require 'colorize'
require 'sqlite3'


def determine_year content
  /\b((my)?(20)?0\d)\b/i.match(content)[1] rescue nil
end

def determine_price content
  /(\$\s*[\d,\.]{0,6}k?)\b |
   (?:price|cost|paid)\s*\:?\s*\$?\s*([\d,\.]{0,6}k?)\b
  /ix.match(content).captures.compact[0] rescue nil
end

def parse_content content
  # objective: get
  #   year
  #   mileage
  #   price
  #   purchase date
  #   location
  #   CR?
  #   color
  #   notes

  year = nil
  mileage = nil
  price = nil
  color = nil

  # determine year
  #   can be double digit (00-09)
  #   or 4 digits (2000-2009)
  #   and optionally preceded by "MY" (model year)
  #   ignore 1999

  year = determine_year content
  content.sub!(year, '') if year

  # determine price
  #   look for full number,
  #   or number followed by k
  #   look for word "price"
  #
  price = determine_price content
  # content.sub!(price, '') if price

  if year
    print "#{year.cyan} "
    if price
      print "#{price.green} "
      puts content
    else
      puts content.yellow
    end
  else
    puts content.yellow
  end

end

# filters

def not_enough_numbers content
  content.scan(/\d/).count < 6
end

def too_many_questions content
  content.scan(/\? |\?$/).count > 1
end


db = SQLite3::Database.new 's2ki.db'

rows = db.execute('SELECT * FROM forum')

# filter entire rows out
rows.reject! do |*, content|
  should_reject = not_enough_numbers(content) || too_many_questions(content)
  #puts "Filtered: #{content}".red if should_reject
  should_reject
end

# # cleanup content, remove noise
rows.map! do |*_, content|
  if content.match(/s2000|s2k/i)
    content.gsub!(/s2000|s2k/i, '')
  end

  [*_, content]
end

rows.each do |row|
  username, published, location, content = row

  parse_content content if content
end

