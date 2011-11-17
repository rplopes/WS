require 'rss'
require 'rubygems'
require 'builder'

file = File.new('articles.xml', 'w')

rss_urls = ["http://feeds.ign.com/ignfeeds/movies/", "http://feeds.ign.com/ignfeeds/tv/", "http://www.comingsoon.net/rss-database-20.php", "http://www.comingsoon.net/trailers/rss-trailers-20.php", "http://www.comingsoon.net/news/rss-main-30.php", "http://news.yahoo.com/rss/movies", "http://feeds2.feedburner.com/NewsInFilm", "http://feeds.feedburner.com/totalfilm/news"]

xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"

xml.articles do
  rss_urls.each do |url|
    rss = RSS::Parser.parse(open(url).read, false)
    rss.items.each do |item|
      xml.article do |n|
        n.title item.title
        n.date item.date
        n.description item.description
        n.link item.link
      end
    end
  end
end

file.close
