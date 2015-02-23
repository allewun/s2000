def extract_year content
  # can be double digit (00-09)
  # or 4 digits (2000-2009)
  # and optionally preceded by "MY" (model year)
  # ignore 1999

  /\b((my)?(20)?0\d)\b/i.match(content)[1] rescue nil
end


def extract_price content
  # look for full number,
  # or number followed by k
  # look for key words

  /(\$\s*[\d,\.]{1,6}k?)\b |
   (?:price|cost|paid)\s*\:?\s*\$?\s*([\d,\.]{1,6}k?)\b
  /ix.match(content).captures.compact[0] rescue nil
end


def extract_miles content
  /\b(\d[\d,\.x]{1,6}k?)\s*(?:mi|miles?|mileage) |
   (?:mi|miles?|mileage)\s*\:?\s*(\d[\d,\.x]{1,6}k?)\b
  /ix.match(content).captures.compact[0] rescue nil
end


def extract_color content
  /(white|platinum|gpw|grand prix|
    silver|sebring|chicane|moonrock|
    black|blk|berlina|
    red|nfr
    yellow|rio|spa|
    lime|green|
    blue|mcb|navy|suzuka|apex|montecarlo|laguna|
    orange)/xi.match(content).captures.compact[0] rescue nil
end


# {year, price, mileage}
def extract_content content
  # objective: get
  #   purchase date
  #   location
  #   CR?
  #   notes

  # puts content.black

  year = extract_year content
  content.sub!(year, '') if year

  price = extract_price content
  content.sub!(price, '') if price

  mileage = extract_miles content
  content.sub!(mileage, '') if mileage

  color = extract_color content
  content.sub!(color, '') if color

  {year:    year,
   price:   price,
   mileage: mileage,
   color:   color}
end
