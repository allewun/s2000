def process_number number
  number.sub!(/[\.,]$/, '')

  # non-american decimal
  number.sub!(/,(\d)$/, '.\1')

  # remove commas
  number.sub!(',', '')

  # multiply by 1000
  if number.match(/k/i)
    number.sub!(/k/i, '')
    number = number.to_f
    number *= 1000 if number < 1000
  end

  number = number.to_f
end


def postprocess_year year
  return nil if !year

  year.sub!(/my/i, '')
  year.sub!(/^(\d{2})$/, '20\1')
  year.to_i
end


def postprocess_price price
  return nil if !price

  price.sub!('$', '')
  price.strip!

  price = process_number price

  # assume missed multiplier
  if price < 35
    price *= 1000
  elsif price < 350
    price *= 100
  end

  price.to_i
end


def postprocess_mileage mileage
  return nil if !mileage

  mileage.gsub!(/x/i, '0')
  mileage = process_number mileage

  # assume missed multiplier
  mileage *= 1000 if mileage < 100

  mileage.to_i
end


def postprocess_color color
  return nil if !color

  case color
  when /white|platinum|gpw|grand prix/
    0
  when /silver|sebring|chicane|moonrock/
    1
  when /black|blk|berlina/
    2
  when /red/
    3
  when /yellow|rio|spa/
    4
  when /lime|green/
    5
  when /blue|mcb|navy|suzuka|apex|montecarlo|laguna/
    6
  when /orange/
    7
  end
end


def postprocess datum
  datum[:year]    = postprocess_year datum[:year]
  datum[:price]   = postprocess_price datum[:price]
  datum[:mileage] = postprocess_mileage datum[:mileage]
  datum[:color]   = postprocess_color datum[:color]
  datum
end
