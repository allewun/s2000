require 'mechanize'
require 'sqlite3'

def scrape
  db = SQLite3::Database.new DATABASE_FILE
  m = Mechanize.new

  link = FORUM_URL

  (1..10000).each do |i|
    puts "  Fetching page #{i}...\n"
    page = m.get(link)
    link = page.search('li.next > a[title="Next page"]').attribute("href").text rescue nil

    # get posts that don't contain quotes
    page.search('.//div[contains(@id, "post_id_")]/div[@class="post_wrap"][not(descendant::div[@class="quote"])]').each do |post|
      published = post.search('abbr.published').attribute('title').text
      author    = post.search('span.author.vcard > a').text
      location  = post.search('.//li[span[@class="ft"]/text() = "Location:"]/span[@class="fc"]').text
      content   = post.search('div.entry-content').xpath('text()').text.strip.gsub(/\s+/, ' ')

      db.execute("INSERT INTO forum (username, published, location, content)
                  VALUES (?, ?, ?, ?)", [author, published, location, content])
    end

    break unless link
  end
end