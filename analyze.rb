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


end


db = SQLite3::Database.new 's2ki.db'

db.execute('SELECT * FROM forum') do |row|
  username, published, location, content = row

  parse_content content
end

