require 'erb'

class Plot
  def initialize(opts={})
    opts.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @x_ticks ||= "'auto'"
    @x_format ||= "''"
    @y_format ||= "''"
    @x_min ||= @x.min
    @x_max ||= @x.max
    @y_min ||= @y.min
    @y_max ||= @y.max

    @template = File.read('plot.html.erb')
    @data = construct_data
  end

  def construct_data
    @data = @x.zip @y
    @data.insert(0, [@x_title, @y_title])
  end

  def render
    ERB.new(@template).result(binding)
  end

  def save
    file = "plots/#{@x_title}-vs-#{@y_title}.html"
    File.open(file, "w+") do |f|
      f.write(render)
    end

    puts "  #{@y_title} vs. #{@x_title}: #{file}"
  end
end
