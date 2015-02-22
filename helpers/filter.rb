# encoding: utf-8

def not_enough_numbers content
  content.scan(/\d/).count < 6
end

def too_many_questions content
  content.scan(/\? |\?$/).count > 1
end

def is_trade content
  content.include? 'trade'
end

def is_international content
  content.match(/canada/i) ||
  content.include?('£')
end
