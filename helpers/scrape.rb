require 'mechanize'
require 'sqlite3'

def scrape
  $db ||= SQLite3::Database.new DATABASE_FILE
  m = Mechanize.new

  link = FORUM_URL

  (1..10000).each do |i|
    puts "  Fetching page #{i}..."
    page = m.get(link)
    link = page.search('li.next > a[title="Next page"]').attribute('href').text rescue nil

    # get posts that don't contain quotes
    page.search('.//div[contains(@id, "post_id_")]/div[@class="post_wrap"][not(descendant::div[@class="quote"])]').each do |post|
      published = post.search('abbr.published').attribute('title').text
      author    = post.search('span.author.vcard > a').text
      location  = post.search('.//li[span[@class="ft"]/text() = "Location:"]/span[@class="fc"]').text
      content   = post.search('div.entry-content').xpath('descendant::text()[not(parent::p/@class="edit")]').text.strip.gsub(/\s+/, ' ')

      begin
        $db.execute('INSERT INTO forum (username, published, location, content)
                    VALUES (?, ?, ?, ?)', [author, published, location, content])
      rescue SQLite3::ConstraintException => e
        # don't insert duplicate
      end
    end

    break unless link
  end
end


def setup_db
  File.delete DATABASE_FILE if File.exist? DATABASE_FILE
  $db ||= SQLite3::Database.new DATABASE_FILE
  $db.execute <<-SQL
    CREATE TABLE forum (
      username  TEXT,
      published TEXT,
      location  TEXT,
      content   TEXT UNIQUE
    );
  SQL
end
