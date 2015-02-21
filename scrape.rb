require 'mechanize'
require 'sqlite3'

db = SQLite3::Database.new 's2ki.db'

rows = db.execute <<-SQL
  create table s2000raw (
    year     integer
    mileage  integer
    price    integer
    purchase text
    location text
    cr       integer
    color    text
    notes    text
    username text
  )
SQL


m = Mechanize.new
