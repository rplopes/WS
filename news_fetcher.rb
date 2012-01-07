require 'open-uri'

(1..9).each do |i|
  url = "http://ws2011.herokuapp.com/fetcher/get_news?s=#{i}"
  open(url) { puts url }
end