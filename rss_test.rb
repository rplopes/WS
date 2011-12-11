require 'rubygems'
require 'rss'
require "rdf"
require "rdf/ntriples"
require 'builder'
require 'sparql/grammar'

#file = File.new('data/articles.xml', 'w')

queryable = RDF::Repository.load("data/tests/graph.nt")
url = "http://feeds.ign.com/ignfeeds/tv/"

rss = RSS::Parser.parse(open(url).read, false)
goodnews = []
rss.items.each do |item|
  if item.title.index(":")
    title = item.title[0..item.title.index(":")-1]
    query = "PREFIX ws: <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#>
             SELECT *
             WHERE
             { ?x ws:hasTitle \"#{title}\" }"
    sse = SPARQL::Grammar.parse(query)
    results = sse.execute(queryable)
    if results.size > 0
      goodnews << {"article" => item, "show" => results.last}
      puts "\"#{item.title}\" (from TV show #{results.last[:x]})"
    end
  end
end



#rss_urls = ["http://feeds.ign.com/ignfeeds/movies/", "http://feeds.ign.com/ignfeeds/tv/", "http://www.comingsoon.net/rss-database-20.php", "http://www.comingsoon.net/trailers/rss-trailers-20.php", "http://www.comingsoon.net/news/rss-main-30.php", "http://news.yahoo.com/rss/movies", "http://feeds2.feedburner.com/NewsInFilm", "http://feeds.feedburner.com/totalfilm/news", "http://www.tv.com/news/news.xml"]

#xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
#xml.instruct! :xml, :encoding => "UTF-8"

#xml.articles do
#  rss_urls.each do |url|
#    rss = RSS::Parser.parse(open(url).read, false)
#    rss.items.each do |item|
#      xml.article do |n|
#        n.title item.title
#        n.date item.date
#        n.description item.description
#        n.link item.link
#      end
#    end
#  end
#end

#file.close
