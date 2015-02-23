require_relative 'plot.rb'

def get_data_xy(data, x_key, y_key, z_key = nil)
  result = {x_key => [], y_key => [], z_key => []}

  # only add x-y pairwise elements if neither are nil
  data.each do |hash|
    if z_key
      if hash[x_key] && hash[y_key] && hash[z_key]
        result[x_key] << hash[x_key]
        result[y_key] << hash[y_key]
        result[z_key] << hash[z_key]
      end
    elsif hash[x_key] && hash[y_key]
      result[x_key] << hash[x_key]
      result[y_key] << hash[y_key]
    end
  end

  result
end


def save_data data
  string = ['YEAR',
            'PRICE',
            'MILEAGE',
            'COLOR',
            'DATE'].join("\t") + "\n"

  data.each do |hash|
    string << [hash[:year],
               hash[:price],
               hash[:mileage],
               hash[:color],
               hash[:date]].join("\t") + "\n"
  end

  file = "#{RESULTS_DIR}/s2k.txt"
  File.open(file, "w+") { |f| f.write string }

  puts "Data saved to #{file}"
end


def analyze data
  data_price_year    = get_data_xy(data, :year, :price)
  data_price_mileage = get_data_xy(data, :mileage, :price)
  data_price_color   = get_data_xy(data, :color, :price)
  data_price_date    = get_data_xy(data, :date, :price, :year)

  prices_vs_years =
    Plot.new({x: data_price_year[:year],
              x_title: 'Years',
              x_ticks: (2000..2009).to_a,
              x_format: '"####"',
              y: data_price_year[:price],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..50000).step(5000).to_a})

  prices_vs_mileage =
    Plot.new({x: data_price_mileage[:mileage],
              x_title: 'Mileage',
              x_format: '"###,###"',
              x_ticks: (0..200000).step(10000).to_a,
              y: data_price_mileage[:price],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..35000).step(5000).to_a})

  prices_vs_color =
    Plot.new({x: data_price_color[:color],
              x_title: 'Color',
              x_ticks: (0..7).to_a,
              y: data_price_color[:price],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..35000).step(5000).to_a})


  prices_vs_date =
    Plot.new({x: data_price_date[:date].zip(data_price_date[:year]).map { |date,year| (date - Time.parse("#{year}-1-1")).to_f / (60*60*24*365) },
              x_title: 'Age when purchased',
              x_ticks: (0..15).to_a,
              y: data_price_date[:price],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..35000).step(5000).to_a})

  prices_vs_years.plot
  prices_vs_mileage.plot
  prices_vs_color.plot
  prices_vs_date.plot
end
