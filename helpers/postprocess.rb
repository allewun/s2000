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
    number *= 1000
  end

  number = number.to_f
end

def postprocess_year year
  year.sub!(/my/i, '')
  year.sub!(/^(\d{2})$/, '20\1')
  year.to_i
end

def postprocess_price price
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
  mileage.gsub!(/x/i, '0')
  mileage = process_number mileage

  # assume missed multiplier
  if mileage < 100
    mileage *= 1000
  end

  mileage.to_i
end
