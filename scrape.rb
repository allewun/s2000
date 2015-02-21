require 'mechanize'
require 'sqlite3'

puts "Starting S2000 data collection...\n"

# setup database
puts "Setting up database...\n"
db = SQLite3::Database.new 's2ki.db'

db.execute <<-SQL
  CREATE TABLE forum (
    username  TEXT,
    published TEXT,
    location  TEXT,
    content   TEXT
  );

  CREATE TABLE s2000 (
    year     INTEGER,
    mileage  INTEGER,
    price    INTEGER,
    purchase TEXT,
    location TEXT,
    cr       INTEGER,
    color    TEXT,
    notes    TEXT,
    username TEXT
  );
SQL


# begin scraping
puts "Beginning to scrape...\n"
m = Mechanize.new

link = 'http://www.s2ki.com/s2000/topic/903878-how-much-did-you-pay-for-your-used-s2000/'

(1..10000).each do |i|
  puts "Fetching page #{i}...\n"
  page = m.get(link)
  link = page.search('li.next > a[title="Next page"]').attribute("href").text rescue nil

  # get posts that don't contain quotes
  page.search('.//div[contains(@id, "post_id_")]/div[@class="post_wrap"][not(descendant::div[@class="quote"])]').each do |post|
    published = post.search('abbr.published').attribute('title').text
    author    = post.search('span.author.vcard > a').text
    location  = post.search('.//li[span[@class="ft"]/text() = "Location:"]/span[@class="fc"]').text
    content   = post.search('div.entry-content').text.gsub(/^\s+|\s+$/, '')

    db.execute("INSERT INTO forum (username, published, location, content)
                VALUES (?, ?, ?, ?)", [author, published, location, content])
  end

  break unless link
end