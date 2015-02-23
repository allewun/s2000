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
  when /red|nfr/
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


def postprocess_date date
  return nil if !date

  year = nil,
  month = nil
  day = 1

  month_names = %w(jan feb mar apr may jun jul aug sept oct nov dec)

  case date
  # british format
  when /201\d(?:\/|\-)\d{1,2}(?:(?:\/|\-)\d{1,2})?/
    parts = date.split(/\/|\-/).map(&:to_i)
    if parts.count == 2
      year, month = parts
    elsif parts.count == 3
      year, month, day = parts
    end

  # american format
  when /(?:\d{1,2}(?:\/|\-))?\d{1,2}(?:\/|\-)201\d/
    parts = date.split(/\/|\-/).map(&:to_i)
    if parts.count == 2
      month, year = parts
    elsif parts.count == 3
      # assume m/d/y first
      month, day, year = parts

      if month > 12
        day, month, year = parts
      end
    end

  # month year
  when /jan|feb|mar|apr|may|jun|jul|aug|sept|oct|nov|dec/i
    month = month_names.index { |m| date.downcase.include? m } + 1
    year = date.gsub(/\D/, '').to_i
  end

  Time.parse("#{year}-#{month}-#{day}")
end


def postprocess datum
  datum[:year]    = postprocess_year datum[:year]
  datum[:price]   = postprocess_price datum[:price]
  datum[:mileage] = postprocess_mileage datum[:mileage]
  datum[:color]   = postprocess_color datum[:color]
  datum[:date]    = postprocess_date datum[:date]
  datum
end
