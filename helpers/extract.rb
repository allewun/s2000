require 'colorize'
require 'sqlite3'

require_relative 'extractors.rb'
require_relative 'filter.rb'
require_relative 'postprocess.rb'

$bad = 0
$good = 0
$filtered = 0

# [{years, prices, mileages}]
def extract
  db = SQLite3::Database.new DATABASE_FILE
  forum_rows = db.execute('SELECT * FROM forum')

  # filter entire rows out
  forum_rows.reject! do |*, content|
    should_reject = not_enough_numbers(content) ||
                    too_many_questions(content) ||
                    is_trade(content) ||
                    is_international(content)

    $filtered += 1 if should_reject

    should_reject
  end

  # cleanup content, remove noise
  forum_rows.map! do |*_, content|
    [*_, content.gsub(/s2000|s2k/i, '')]
  end

  # extract data from forum post content
  data = forum_rows.map do |usermame, published, location, content|
    # extract desired values, still need to be cleaned up
    datum = extract_content content

    # cleanup extracted data
    postprocess datum
  end

  puts "  Filtered #{$filtered} rows"
  puts "  #{$good} / #{$good + $bad} complete rows"

  data
end