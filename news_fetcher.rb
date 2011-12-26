require 'rubygems'
require 'rss'
require "rdf"
require "rdf/ntriples"
require 'builder'
require 'sparql/grammar'
require 'rails'
require 'rdf/do'
require 'do_sqlite3'

if Rails.env.production?
  TRIPLE_STORE =  RDF::DataObjects::Repository.new('postgres://susxgkmcos:cip7T9ZvmiKFZSYzn0pJ@ec2-107-22-249-232.compute-1.amazonaws.com/susxgkmcos')
else 
  TRIPLE_STORE =  RDF::DataObjects::Repository.new('sqlite3:triple_store.db')
  Article.rebuild_index
end
REPOSITORY = RDF::Repository.new << TRIPLE_STORE

WS = RDF::Vocabulary.new("http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#")

def data
  return RDF::Vocabulary.new("http://ws2011.herokuapp.com/semantic/")
end

def query(query_string)
  SPARQL::Grammar.parse(query_string).execute(REPOSITORY)
end 

def insert_article(article, results)
  if results["people"]
    results["people"].each do |result|
      subject = RDF::URI.new article.uri
      predicate = WS.talksAboutPerson
      object = RDF::URI.new result[:x]
      TRIPLE_STORE << [subject, predicate, object]
      REPOSITORY << [subject, predicate, object]
    end
  else
    results["shows"].each do |result|
      subject = RDF::URI.new article.uri
      predicate = WS.talksAboutShow
      object = RDF::URI.new result[:x]
      TRIPLE_STORE << [subject, predicate, object]
      REPOSITORY << [subject, predicate, object]
    end
  end
end

def get_news
  @news = []
  count = -1
  
  # Fetch TV show news from IGN
  articles = fetch_articles("http://feeds.ign.com/ignfeeds/tv/")
  @news << get_tvshows(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          :creator => news[:article].author,
                          :source => "IGN TV")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch movie reviews and people news from IGN
  articles = fetch_articles("http://feeds.ign.com/ignfeeds/movies/")
  @news << get_people(articles)
  @news << get_reviews(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          :source => "IGN Movies")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          :source => "IGN Movies")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch Movies news from ComingSoon
  articles = fetch_articles("http://www.comingsoon.net/rss-database-20.php")
  @news << get_movies(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => DateTime.now,
                          :source => "ComingSoon")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch People news from ComingSoon
  articles = fetch_articles("http://www.comingsoon.net/news/rss-main-30.php")
  @news << get_people(articles)
  count += 1
  @news[count].each do |news|
    puts "Article!!!"
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => DateTime.now,
                          :source => "ComingSoon People")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch movie news from ComingSoon
  articles = fetch_articles("http://www.comingsoon.net/trailers/rss-trailers-20.php")
  @news << get_movies(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => DateTime.now,
                          :source => "ComingSoon Trailers")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch TV show news from TV.COM
  articles = fetch_articles("http://www.tv.com/news/news.xml")
  @news << get_tvshows(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          :creator => news[:article].author,
                          :source => "TV.COM")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch people news from Yahoo Movies
  articles = fetch_articles("http://news.yahoo.com/rss/movies")
  @news << get_people(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          :source => "Yahoo Movies")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end

  # Fetch movie reviews and people news from News in Film
  articles = fetch_articles("http://feeds2.feedburner.com/NewsInFilm")
  @news << get_people(articles)
  @news << get_reviews(articles)
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          #:creator => news[:article]["dc:creator"],
                          :source => "News In Film")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end
  count += 1
  @news[count].each do |news|
    article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                          :title => news[:article].title,
                          :link => news[:article].link,
                          :description => news[:article].description,
                          :date => news[:article].pubDate.to_date,
                          #:creator => news[:article]["dc:creator"],
                          :source => "News In Film")
    if not Article.find_by_uri(article.uri)
      article.save
      article.ferret_update if Rails.env.development?
      insert_article(article, news)
    end
  end
  
  @news.each do |sitenews|
    sitenews.each do |sitenew|
      if sitenew["shows"]
        sitenew["shows"].each do |show|
          puts "#{sitenew[:article].title} (about the show #{show[:x]})"
        end
      end
      if sitenew["people"]
        sitenew["people"].each do |person|
          puts "#{sitenew[:article].title} (about the person #{person[:x]})"
        end
      end
    end
  end
end

private

def fetch_articles(url)
  rss = RSS::Parser.parse(open(url).read, false)
  return rss.items
end

# Fetch news about TV shows
def get_tvshows(articles)
  goodnews = []
  articles.each do |article|
    return goodnews if Article.find_by_uri(data[article.link.gsub(/[^A-z0-9]/,'')].to_s)
    if article.title.index(":")
      title = article.title[0..article.title.index(":")-1].gsub('"', '\"')
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
      results = query(q)
      goodnews << {:article => article, "shows" => results} if results.size > 0
    end
  end
  return goodnews
end

# Fetch news about movies
def get_movies(articles)
  goodnews = []
  articles.each do |article|
    return goodnews if Article.find_by_uri(data[article.link.gsub(/[^A-z0-9]/,'')].to_s)
    title = article.title.gsub('"', '\"')
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
    results = query(q)
    # If results.size == 0 do screen scraping
    goodnews << {:article => article, "shows" => results} if results.size > 0
  end
  return goodnews
end

#Fetch news about actors, directors and creators
def get_people(articles)
  goodnews = []
  articles.each do |article|
    return goodnews if Article.find_by_uri(data[article.link.gsub(/[^A-z0-9]/,'')].to_s)
    title = article.title.gsub('"', '\"')
    words = title.split(/[\s,]+/)
    for first in 0..words.size-1
      unless words[first] =~ /^[a-z\-\&].*/
        name = ""
        for last in first..words.size-1
          name = words[first..last].join(" ")
          name =~ /^[ ]+.*/ ? tempname = name[0..-3] : tempname = name
          q = "SELECT *
               WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{tempname}\" .
                       ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Actor> }"
          results = query(q)
          goodnews << {:article => article, "people" => results} if results.size > 0
          if results.size == 0
            q = "SELECT *
                 WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{tempname}\" .
                       ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Director> }"
            results = query(q)
            goodnews << {:article => article, "people" => results} if results.size > 0
            if results.size == 0
              q = "SELECT *
                   WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{tempname}\" .
                       ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Creator> }"
              results = query(q)
              goodnews << {:article => article, "people" => results} if results.size > 0
            end
          end
        end
      end
    end
  end
  return goodnews
end

# Fetch news about movies reviews
def get_reviews(articles)
  goodnews = []
  articles.each do |article|
    return goodnews if Article.find_by_uri(data[article.link.gsub(/[^A-z0-9]/,'')].to_s)
    if article.title =~ /.+ Review/
      title = article.title[0..-1-" Review".size].gsub('"', '\"')
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
      # If results.size == 0 do screen scraping
      results = query(q)
      goodnews << {:article => article, "shows" => results} if results.size > 0
    end
  end
  return goodnews
end

get_news