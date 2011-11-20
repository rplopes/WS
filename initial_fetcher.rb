require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'builder'
require 'rss'
require 'rexml/document'

########################################################################
#                                                                      #
#          Benchmarking                                                #
#          It took from 12:49:40 to ? to fetch all movies       #
#          It took from ? to ? to fetch all TV shows     #
#                                                                      #
########################################################################

puts "#{Time.now}\tShall we start?"

########################################################################
#                                                                      #
#          Class definitions                                           #
#                                                                      #
########################################################################

class Movie
  attr_accessor :name, :directors, :franchise, :genres, :actors

  def initialize(name, directors = "", genres = "", actors = "", franchise = "")
    @name = name
    @directors = directors
    @genres = genres
    @actors = actors
    @franchise = franchise
  end
end

class TvShow
  attr_accessor :name, :creators, :genres, :actors, :network

  def initialize(name, creators = "", genres = "", actors = "", network = "")
    @name = name
    @creators = creators
    @genres = genres
    @actors = actors
    @network = network
  end
end

all_movies = []
all_tvshows = []
all_directors = []
all_creators = []
all_actors = []
all_genres = []
all_franchises = []
all_networks = []

########################################################################
#                                                                      #
#          Saving articles from RSS                                    #
#                                                                      #
########################################################################

#puts "#{Time.now}\tSaving articles from RSS"

#file = File.new('data/articles.xml', 'w')

#rss_urls = ["http://feeds.ign.com/ignfeeds/movies/", "http://feeds.ign.com/ignfeeds/tv/", "http://www.comingsoon.net/rss-database-20.php", "http://www.comingsoon.net/trailers/rss-trailers-20.php", "http://www.comingsoon.net/news/rss-main-30.php", "http://news.yahoo.com/rss/movies", "http://feeds2.feedburner.com/NewsInFilm", "http://feeds.feedburner.com/totalfilm/news"]

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

########################################################################
#                                                                      #
#          Lets fetch some movies!                                     #
#                                                                      #
########################################################################

puts "#{Time.now}\tLet's fetch some movies!"

site = "http://www.themoviedb.org"
url = "/movie/top-rated"

pages = 1..15
pages.each do |p|
  page = "?page=#{p}"
  doc = Nokogiri::HTML(open(site+url+page))
  puts "#{Time.now}\t#{site+url+page}"
  doc.css(".item").each_with_index do |item,i|
    #break if i == 5
    link = item.at_css(".info h4 a")[:href]
    begin
		  movie_doc = Nokogiri::HTML(open(site+link))
		  name = movie_doc.at_css("#mainCol .title h2#title a").content.to_s
		  raise 'No name' if name.size < 1
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
		        all_franchises << franchise unless all_franchises.index(franchise)
		        break
		      end
		    end
		  rescue
		  end
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
		    all_genres << genre unless all_genres.index(genre)
		  end
		
		  movie_doc = Nokogiri::HTML(open(site+link+"/cast"))
		  directors = []  
		  movie_doc.css("#mainCol table#Directing tbody tr").each do |a|
		    director = a.at_css("td.person a").content.to_s
		    directors << director unless directors.index(director)
		    all_directors << director unless all_directors.index(director)
		  end
		  actors = []
		  movie_doc.css("#mainCol table#castTable tbody tr").each do |a|
		    actor = a.at_css("td.person a").content.to_s
		    if actor != nil and actor.size > 0
		      actors << actor unless actors.index(actor)
		      all_actors << actor unless all_actors.index(actor)
		    end
		  end
		  raise 'No people' if directors.size == 0 and actors.size == 0
		  movie = Movie.new(name, directors, genres, actors, franchise)
		  all_movies << movie unless all_movies.index(movie)
	  rescue
	  end
  end

end

puts "#{Time.now}\t#{all_movies.size} movies found"

file = File.new('data/movies.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.movies do
  all_movies.each do |movie|
    xml.movie do |m|
      m.name movie.name
      m.franchise movie.franchise
      m.directors do |d|
        movie.directors.each do |director|  
          d.director director 
        end    
      end
      m.genres do |g|
        movie.genres.each do |genre|  
          g.genre genre 
        end    
      end
      m.actors do |a|
        movie.actors.each do |actor|  
          a.actor actor
        end    
      end    
    end
  end
end
file.close

########################################################################
#                                                                      #
#          Lets fetch some TV shows!                                   #
#                                                                      #
########################################################################

puts "#{Time.now}\tLet's fetch some TV shows"

site = "http://www.tv.com"
url = "/shows/"

pages = 1..10
pages.each do |p|
  page = "?pg=#{p}"
  doc = Nokogiri::HTML(open(site+url+page))
  puts "#{Time.now}\t#{site+url+page}"
  doc.css(".featured, .show").each_with_index do |item,i|
    #break if i == 5
    begin
      link = item.at_css("a.title")[:href]
      tvshow_doc = Nokogiri::HTML(open(link))
      site_name = " - TV.com"  
      name = tvshow_doc.at_css("title").content.to_s
      name = name[0,name.size-site_name.size]
      raise 'No name' if name.size < 1
      network = ""
      begin
        network = tvshow_doc.at_css(".tagline").content.to_s.split[4..-1].join(" ")
        if network != nil and network.size > 0 and network.index(")") == nil
          all_networks << network unless all_networks.index(network)
        end
      rescue
      end
      genres=[]
      tvshow_doc.css("p[itemprop='genre'] a").each do |g|
        genre = g.content.to_s
        genre = "Sci-Fi" if genre == "Science Fiction"
        if genre == "Action/Suspense"
          genre = "Action"
          genres << genre unless genres.index(genre)
          all_genres << genre unless all_genres.index(genre)
          genre = "Suspense"
        end
        genres << genre unless genres.index(genre)
        all_genres << genre unless all_genres.index(genre)
      end
      
      tvshow_doc = Nokogiri::HTML(open(link+"cast/?flag=3"))
      creators = []  
      tvshow_doc.css(".list.first ul.people li.person .info h4 a").each do |c|
        creator = c.content.to_s
        creators << creator unless creators.index(creator)
        all_creators << creator unless all_creators.index(creator)
      end

      tvshow_doc = Nokogiri::HTML(open(link+"cast/?flag=1"))
      actors = []
      tvshow_doc.css("ul.people li.person .info h4 a").each do |a|
        actor = a.content.to_s
        if actor != nil and actor.size > 0
          actors << actor unless actors.index(actor)
          all_actors << actor unless all_actors.index(actor)
        end
      end
      raise 'No people' if creators.size == 0 and actors.size == 0
      tvshow = TvShow.new(name, creators, genres, actors, network)
      all_tvshows << tvshow unless all_tvshows.index(tvshow)
    rescue
    end
  end
end

puts "#{Time.now}\t#{all_tvshows.size} TV shows found"

file = File.new('data/tvshows.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.tvshows do
  all_tvshows.each do |tvshow|
    xml.tvshow do |s|
      s.name tvshow.name
      s.network tvshow.network
      s.creators do |c|
        tvshow.creators.each do |creator|  
          c.creator creator 
        end    
      end
      s.genres do |g|
        tvshow.genres.each do |genre|  
          g.genre genre 
        end    
      end
      s.actors do |a|
        tvshow.actors.each do |actor|  
          a.actor actor
        end    
      end    
    end
  end
end
file.close

########################################################################
#                                                                      #
#          Saving other data                                           #
#                                                                      #
########################################################################

puts "#{Time.now}\tSaving other data"

file = File.new('data/directors.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.directors do
  all_directors.each do |director|  
    xml.director do |d|
      d.name director
    end
  end
end
file.close

file = File.new('data/creators.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.creators do
  all_creators.each do |creator|  
    xml.creator do |c|
      c.name creator
    end
  end
end
file.close

file = File.new('data/actors.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.actors do
  all_actors.each do |actor|  
    xml.actor do |a|
      a.name actor
    end
  end
end
file.close

file = File.new('data/genres.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.genres do
  all_genres.each do |genre|  
    xml.genre do |g|
      g.name genre
    end
  end
end
file.close

file = File.new('data/franchises.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.franchises do
  all_franchises.each do |franchise|  
    xml.franchise do |f|
      f.name franchise
    end
  end
end
file.close

file = File.new('data/networks.xml', 'w')
xml = Builder::XmlMarkup.new( :target => file, :indent => 2)
xml.instruct! :xml, :encoding => "UTF-8"
xml.networks do
  all_networks.each do |network|  
    xml.network do |n|
      n.name network
    end
  end
end
file.close

puts "#{Time.now}\tAll done!"
