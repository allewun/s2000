require_relative 'plot.rb'

def get_data_xy(data, x_key, y_key)
  result = {x: [], y: []}

  # only add x-y pairwise elements if neither are nil
  data.each do |hash|
    if hash[x_key] && hash[y_key]
      result[:x] << hash[x_key]
      result[:y] << hash[y_key]
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
  data_price_date    = get_data_xy(data, :date, :price)

  prices_vs_years =
    Plot.new({x: data_price_year[:x],
              x_title: 'Years',
              x_ticks: (2000..2009).to_a,
              x_format: '"####"',
              y: data_price_year[:y],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..50000).step(5000).to_a})

  prices_vs_mileage =
    Plot.new({x: data_price_mileage[:x],
              x_title: 'Mileage',
              x_format: '"###,###"',
              x_ticks: (0..200000).step(10000).to_a,
              y: data_price_mileage[:y],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..35000).step(5000).to_a})

  prices_vs_color =
    Plot.new({x: data_price_color[:x],
              x_title: 'Color',
              x_ticks: (0..7).to_a,
              y: data_price_color[:y],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..35000).step(5000).to_a})

  prices_vs_date =
    Plot.new({x: data_price_date[:x],
              x_title: 'Date',
              y: data_price_date[:y],
              y_title: 'Price',
              y_format: '"$##,###"',
              y_ticks: (0..35000).step(5000).to_a})

  prices_vs_years.plot
  prices_vs_mileage.plot
  prices_vs_color.plot
  prices_vs_date.plot
end
