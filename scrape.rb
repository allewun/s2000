require 'mechanize'
require 'sqlite3'

# db = SQLite3::Database.new 's2ki.db'

# rows = db.execute <<-SQL
#   create table forum (
#     username text
#     publised text
#     location text
#     content  text
#   );

#   create table s2000 (
#     year     integer
#     mileage  integer
#     price    integer
#     purchase text
#     location text
#     cr       integer
#     color    text
#     notes    text
#     username text
#   );
# SQL

m = Mechanize.new
page = m.get('http://www.s2ki.com/s2000/topic/903878-how-much-did-you-pay-for-your-used-s2000/')

# get posts that don't contain quotes
page.search('.//div[contains(@id, "post_id_")]/div[@class="post_wrap"][not(descendant::div[@class="quote"])]').each do |post|
  published = post.search('abbr.published').attribute('title').text
  author    = post.search('span.author.vcard > a').text
  location  = post.search('.//li[span[@class="ft"]/text() = "Location:"]/span[@class="fc"]').text
  content   = post.search('div.entry-content').text.gsub(/^\s+|\s+$/, '')

  data = {published: published,
          author: author,
          location: location,
          content: content}

  pp data
end
