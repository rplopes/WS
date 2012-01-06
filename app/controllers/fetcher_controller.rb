require 'rss'
require 'rexml/document'
require 'open-uri'
require 'rdf'
require 'date'

class FetcherController < ApplicationController
  
  def test_movies
    @titles = []
    
    doc = REXML::Document.new File.new('data/movies.xml')
    doc.elements.each("movies/movie") do |movie|
      @titles << movie.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched movies (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_tvshows
    @titles = []
    
    doc = REXML::Document.new File.new('data/tvshows.xml')
    doc.elements.each("tvshows/tvshow") do |tvshow|
      @titles << tvshow.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched TV shows (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_directors
    @titles = []
    
    doc = REXML::Document.new File.new('data/directors.xml')
    doc.elements.each("directors/director") do |director|
      @titles << director.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched directors (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_creators
    @titles = []
    
    doc = REXML::Document.new File.new('data/creators.xml')
    doc.elements.each("creators/creator") do |creator|
      @titles << creator.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched creators (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_actors
    @titles = []
    
    doc = REXML::Document.new File.new('data/actors.xml')
    doc.elements.each("actors/actor") do |actor|
      @titles << actor.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched actors (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_genres
    @titles = []
    
    doc = REXML::Document.new File.new('data/genres.xml')
    doc.elements.each("genres/genre") do |genre|
      @titles << genre.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched genres (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_networks
    @titles = []
    
    doc = REXML::Document.new File.new('data/networks.xml')
    doc.elements.each("networks/network") do |network|
      @titles << network.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched networks (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  def test_franchises
    @titles = []
    
    doc = REXML::Document.new File.new('data/franchises.xml')
    doc.elements.each("franchises/franchise") do |franchise|
      @titles << franchise.elements['name'].text
    end
    @titles = @titles.sort
    @page_title = "Fetched franchises (#{@titles.length})"
    render "fetcher/fetcher"
  end
  
  # Fetch the latest news

  def get_news
    @titles = []

    source = params[:s]
    if source
      @news = get_news_from_source(source)
      @page_title = source

      @news.each do |sitenews|
        sitenews.each do |sitenew|
          if sitenew["shows"]
            sitenew["shows"].each do |show|
              @titles << "#{sitenew[:article].title} (about the show #{show[:x]})"
            end
          end
          if sitenew["people"]
            sitenew["people"].each do |person|
              @titles << "#{sitenew[:article].title} (about the person #{person[:x]})"
            end
          end
        end
      end
    end
    
    render "fetcher/fetcher"
  end
    
  def get_news_from_source(source)
    @news = []
    count = -1

    if source.eql? "1" # Fetch TV show news from IGN
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
    end

    if source.eql? "2" # Fetch movie reviews and people news from IGN
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
    end

    if source.eql? "3" # Fetch Movies news from ComingSoon
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
    end

    if source.eql? "4" # Fetch People news from ComingSoon
      articles = fetch_articles("http://www.comingsoon.net/news/rss-main-30.php")[0..10]
      @news << get_people(articles)
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
    end

    if source.eql? "5" # Fetch movie news from ComingSoon
      articles = fetch_articles("http://www.comingsoon.net/trailers/rss-trailers-20.php")
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
    end

    if source.eql? "6" # Fetch TV show news from TV.COM
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
    end

    if source.eql? "7" # Fetch people news from Yahoo Movies
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
    end

    if source.eql? "8" # Fetch movie reviews and people news from News in Film
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
    end

    if source.eql? "9" # Fetch people news from NYT Movies
      temp_articles = fetch_articles("http://feeds.nytimes.com/nyt/rss/Movies")
      articles = []
      temp_articles.each do |ta|
        articles << ta unless ta.title =~ /Movie Review /
        break if articles.size >= 10
      end
      @news << get_people(articles)
      count += 1
      @news[count].each do |news|
        article = Article.new(:uri => data[news[:article].link.gsub(/[^A-z0-9]/,'')].to_s,
                              :title => news[:article].title,
                              :link => news[:article].link,
                              :description => news[:article].description,
                              :date => news[:article].pubDate.to_date,
                              :source => "NYT Movies")
        if not Article.find_by_uri(article.uri)
          article.save
          article.ferret_update if Rails.env.development?
          insert_article(article, news)
        end
      end
    end

    return @news
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
      if results.size == 0
        fetch_movie_info(article.title)
        q = "SELECT *
             WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
        results = query(q)
      end
      goodnews << {:article => article, "shows" => results} if results.size > 0
    end
    return goodnews
  end

  # Fetch news about movies reviews
  def get_reviews(articles)
    goodnews = []
    articles.each do |article|
      return goodnews if Article.find_by_uri(data[article.link.gsub(/[^A-z0-9]/,'')].to_s)
      if article.title =~ /.+ Review$/
        title = article.title[0..-1-" Review".size].gsub('"', '\"')
        q = "SELECT *
             WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
        results = query(q)
        # If results.size == 0 do screen scraping
        if results.size == 0
          puts ">#{article.title[0..-1-" Review".size]}<"
          fetch_movie_info(article.title[0..-1-" Review".size])
          q = "SELECT *
               WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
          results = query(q)
        end
        goodnews << {:article => article, "shows" => results} if results.size > 0
      end
    end
    return goodnews
  end

  #Fetch news about actors, directors and creators
  def get_people(articles)
    goodnews = []
    articles.each do |article|
      return goodnews if Article.find_by_uri(data[article.link.gsub(/[^A-z0-9]/,'')].to_s)
      puts "#{Time.now}\tVisiting an article"
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
                         ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type }"
            results = query(q)
            if results.size > 0
              prefix = "http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#"
              results.each do |result|
                type = result[:type].to_s
                unless type.eql? prefix+"Actor" or type.eql? prefix+"Director" or type.eql? prefix+"Creator"
                  results.delete(result)
                end
              end
            end
            goodnews << {:article => article, "people" => results} if results.size > 0
          end
        end
      end
    end
    return goodnews
  end

  def fetch_movie_info(title)
    search_title = title.gsub(' ', '+')
    movie_doc = Nokogiri::HTML(open("http://www.themoviedb.org/search?search=#{search_title}"))
    begin
      # Franchise
      franchise = ""
      begin
        movie_doc.css("#leftCol p").each do |p|
          if p.at_css("strong").content.to_s == "Part of the:"
            franchise = p.at_css("a").content.to_s.split
            if franchise[-1] == "Collection"
              franchise = franchise[0..-2].join(" ")
            else
              franchise = franchise.join(" ")
            end
            break
          end
        end
      rescue
      end
      # Genres
      genres=[]
      movie_doc.css('#mainCol span#genres ul.tags li').each do |g|
        genre = g.at_css('a').content.to_s
        genre = "Sci-Fi" if genre == "Science Fiction"
        if genre == "Sci-Fi & Fantasy"
          genre = "Sci-Fi"
          genres << genre unless genres.index(genre)
          all_genres << genre unless all_genres.index(genre)
          genre = "Fantasy"
        end
        genres << genre unless genres.index(genre)
      end
      # People
      link = movie_doc.at_css("#mainCol .more a").first[1]
      movie_doc = Nokogiri::HTML(open(link))
      directors = []  
      movie_doc.css("#mainCol table#Directing tbody tr").each do |a|
        director = a.at_css("td.person a").content.to_s
        directors << director unless directors.index(director)
      end
      actors = []
      movie_doc.css("#mainCol table#castTable tbody tr").each do |a|
        actor = a.at_css("td.person a").content.to_s
        if actor != nil and actor.size > 0
          actors << actor unless actors.index(actor)
        end
      end
      raise 'No people' if directors.size == 0 and actors.size == 0

      # Save it
      if franchise and franchise.size > 0
        q = "SELECT *
             WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{franchise}\" .
                     ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Franchise> }"
        results = query(q)
        insert_franchise(franchise) if results.size == 0
      end
      genres.each do |genre|
        q = "SELECT *
             WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{genre}\" .
                     ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Genre> }"
        results = query(q)
        insert_genre(genre) if results.size == 0
      end
      directors.each do |director|
        q = "SELECT *
             WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{director}\" .
                     ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Director> }"
        results = query(q)
        insert_director(director) if results.size == 0
      end
      actors.each do |actor|
        q = "SELECT *
             WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{actor}\" .
                     ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Actor> }"
        results = query(q)
        insert_actor(actor) if results.size == 0
      end
      puts "going to insert #{title}"
      insert_movie(title, franchise, genres, directors, actors)
    rescue
    end
  end

end