require 'colorize'
require 'sqlite3'



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
  # match years, can be double digit (00-09)
  #              or 4 digits (2000-2009)
  #              and optionally preceded by "MY" (model year)
  content.sub(/\b((my)?(20)?0\d)\b/i) { year = $1 }

  if year
    p year
  else
    p content
  end

end

# filters

def not_enough_numbers content
  content.scan(/\d/).count < 6
end

def too_many_questions content
  content.scan('? ').count > 1
end


db = SQLite3::Database.new 's2ki.db'

rows = db.execute('SELECT * FROM forum')

rows.reject! do |*, content|
  should_reject = not_enough_numbers(content) || too_many_questions(content)
  puts "Filtered: #{content}".red if should_reject
  should_reject
end

rows.each do |row|
  username, published, location, content = row

  parse_content content if content
end

