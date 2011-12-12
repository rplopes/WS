require 'rubygems'
require 'rss'
require "rdf"
require "rdf/ntriples"
require 'builder'
require 'sparql/grammar'

def fetch_articles(url)
  rss = RSS::Parser.parse(open(url).read, false)
  return rss.items
end

# Fetch news about actors, directors and creators
def get_people(articles, r)
  goodnews = []
  articles.each do |article|
    title = article.title.gsub('"', '\"')
    words = title.split(/[\s,]+/)
    for first in 0..words.size-1
      unless words[first] =~ /^[a-z\-\&].*/
        name = ""
        for last in first..words.size-1
          name = words[first..last].join(" ")
          name =~ /^[ ]+.*/ ? tempname = name[0..-3] : tempname = name
          query = "PREFIX ws: <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#>
                   SELECT ?x
                   WHERE { ?x ws:hasName \"#{tempname}\" }"
          results = SPARQL::Grammar.parse(query).execute(r)
          if results.size > 0
            goodnews << {"article" => article, "person" => results.last}
            puts "\"#{article.title}\" (about #{results.last[:x]})"
          end
        end
      end
    end
  end
  return goodnews
end

# Fetch news about TV shows
def get_tvshows(articles, r)
  goodnews = []
  articles.each do |article|
    if article.title.index(":")
      title = article.title[0..article.title.index(":")-1].gsub('"', '\"')
      query = "PREFIX ws: <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#>
               SELECT ?x
               WHERE { ?x ws:hasTitle \"#{title}\" }"
      results = SPARQL::Grammar.parse(query).execute(r)
      if results.size > 0
        goodnews << {"article" => article, "show" => results.last}
        puts "\"#{article.title}\" (from TV show #{results.last[:x]})"
      end
    end
  end
  return goodnews
end

# Fetch news about movies reviews
def get_reviews(articles, r)
  goodnews = []
  articles.each do |article|
    if article.title =~ /.+ Review/
      title = article.title[0..-1-" Review".size].gsub('"', '\"')
      query = "PREFIX ws: <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#>
               SELECT ?x
               WHERE { ?x ws:hasTitle \"#{title}\" }"
      results = SPARQL::Grammar.parse(query).execute(r)
      # If results.size == 0 do screen scraping
      if results.size > 0
        goodnews << {"article" => article, "show" => results.last}
        puts "\"#{article.title}\" (from movie #{results.last[:x]})"
      end
    end
  end
  return goodnews
end

# Fetch news about movies
def get_movies(articles, r)
  goodnews = []
  articles.each do |article|
    title = article.title.gsub('"', '\"')
    query = "PREFIX ws: <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#>
             SELECT ?x
             WHERE { ?x ws:hasTitle \"#{title}\" }"
    results = SPARQL::Grammar.parse(query).execute(r)
     # If results.size == 0 do screen scraping
    if results.size > 0
      goodnews << {"article" => article, "show" => results.last}
      puts "\"#{article.title}\" (from movie #{results.last[:x]})"
    end
  end
  return goodnews
end

puts Time.now
r = RDF::Repository.load("data/tests/graph.nt")
news = []


# Fetch TV show news from IGN
puts "\nTV show news from IGN"
articles = fetch_articles("http://feeds.ign.com/ignfeeds/tv/")
news << get_tvshows(articles, r)

# Fetch TV show news from TV.com
puts "\nTV show news from TV.com"
articles = fetch_articles("http://www.tv.com/news/news.xml")
news << get_tvshows(articles, r)

# Fetch movie news from ComingSoon
puts "\nMovie news from ComingSoon"
articles = fetch_articles("http://www.comingsoon.net/rss-database-20.php")
news << get_movies(articles, r)

# Fetch movie news from ComingSoon
puts "\nMovie news from ComingSoon"
articles = fetch_articles("http://www.comingsoon.net/trailers/rss-trailers-20.php")
news << get_movies(articles, r)

# Fetch people news from ComingSoon
puts "\nPeople news from ComingSoon"
articles = fetch_articles("http://www.comingsoon.net/news/rss-main-30.php")
news << get_people(articles, r)

# Fetch people news from Yahoo Movies
puts "\nPeople news from Yahoo Movies"
articles = fetch_articles("http://news.yahoo.com/rss/movies")
news << get_people(articles, r)

# Fetch movie reviews and people news from IGN
puts "\nmovie reviews and people news from IGN"
articles = fetch_articles("http://feeds.ign.com/ignfeeds/movies/")
news << get_people(articles, r)
news << get_reviews(articles, r)

# Fetch movie reviews and people news from News in Film
puts "\nmovie reviews and people news from News in Film"
articles = fetch_articles("http://feeds2.feedburner.com/NewsInFilm")
news << get_people(articles, r)
news << get_reviews(articles, r)
puts Time.now
