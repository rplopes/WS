require 'rss'
require 'rexml/document'
require 'open-uri'

class FetcherController < ApplicationController

  def init
    movies = []
    tvshows = []
    genres = []
    directors = []
    creators = []
    actors = []
    
    #fetch_articles
    fetch_movies(movies, genres, directors, actors)
    
    @page_title = "Browse"
    render "home/browse"
  end
  
  private
  
  def fetch_articles
    file = File.new('data/articles.xml', 'w')

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
  end
  
  def fetch_movies(movies, genres, directors, actors)
    site = "http://www.themoviedb.org"
    url = "/movie/top-rated"
    pages = 1..15
    
    # Each page
    pages.each do |p|
      page = "?page=#{p}"
      doc = Nokogiri::HTML(open(site+url+page))
      
      # Each movie
      doc.css(".item").each do |item|
        link = item.at_css(".info h4 a")[:href]
        begin
          movie_doc = Nokogiri::HTML(open(site+link))
          movie = {}
          movie["name"] = movie_doc.at_css("#mainCol .title h2#title a").content.to_s
          
          # Genres
          movie["genres"] = []
          movie_doc.css('#mainCol span#genres ul.tags li').each do |g|
            genre = g.at_css('a').content.to_s
            movie["genres"] << genre unless movie["genres"].index(genre)
            genres << genre unless genres.index(genre)
          end
          
          # Cast
          movie_doc = Nokogiri::HTML(open(site+link+"/cast"))
          movie["directors"] = []
          movie_doc.css("#mainCol table#Directing tbody tr").each do |a|
            director = a.at_css("td.person a").content.to_s
            movie["directors"] << director unless movie["directors"].index(director)
            directors << director unless directors.index(director)
          end
          movie["actors"] = []
          movie_doc.css("#mainCol table#castTable tbody tr").each do |a|
            actor = a.at_css("td.person a").content.to_s
            movie["actors"] << actor unless movie["actors"].index(actor)
            actors << actor unless actors.index(actor)
          end
          
          # Save
          movies << movie unless movies.index(movie)
        rescue
        end
      end
    end
    
    # Save movies
    file = File.new('data/movies.xml', 'w')
    xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
    xml.instruct! :xml, :encoding => "UTF-8"
    xml.movies do
      movies.each do |movie|
        xml.movie do |m|
          m.name movie["name"]
          m.genres do |g|
            movie["genres"].each do |genre|  
              g.genre genre 
            end    
          end
          m.directors do |d|
            movie["directors"].each do |director|  
              d.director director 
            end    
          end
          m.actors do |a|
            movie["actors"].each do |actor|  
              a.actor actor
            end    
          end    
        end
      end
    end
    file.close
  end
  
end
