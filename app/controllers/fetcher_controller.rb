require 'rss'
require 'rexml/document'
require 'open-uri'

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
    @news = []
    
    # Fetch TV show news from IGN
    articles = fetch_articles("http://feeds.ign.com/ignfeeds/tv/")
    @news << get_tvshows(articles)
    
    @news.each do |sitenews|
      sitenews.each do |new|
        new["shows"].each do |show|
          @titles << "#{new[:article].title} (about the TV show #{show[:x]})"
        end
      end
    end
    
    # Guardar as notícias!!!
    
    render "fetcher/fetcher"
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
  
end
