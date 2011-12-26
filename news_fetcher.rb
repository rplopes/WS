require 'open-uri'

(1..8).each do |i|
  url = "http://ws2011.herokuapp.com/fetcher/get_news?s=#{i}"
  open(url) { puts url }
end