require 'rss'

class HomeController < ApplicationController

  def index
    if current_user
      suggestions
      render :suggestions
    else
      latest_news
      render :latest_news
    end
  end
  
  def latest_news
    @page_title = "Latest news"
    @titles = []
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
    
    doc = REXML::Document.new File.new('data/articles.xml')
    doc.elements.each("articles/article") do |article|
      @titles << article.elements["title"].text
    end
  end
  
  def browse
    @page_title = "Browse"
  end
  
  def search
    @page_title = "Search"
  end
  
  def suggestions
    if current_user
      user
      @page_title = "Suggestions for " + @user.name
    else
      @page_title = "Suggestions for me"
    end
  end
  
  private
  
  def user
    @user = FbGraph::User.me(session[:omniauth]['credentials']['token']).fetch
    @likes = @user.likes
    @movies = []
    @tvshows = []
    @likes.each do |like|
      @movies << like if like.category === 'Movie'
      @tvshows << like if like.category === 'Tv show'
    end
    logger.info @user
  end
end
