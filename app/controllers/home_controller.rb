require 'rss'
require 'rexml/document'

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
    
#    doc = REXML::Document.new File.new('data/articles.xml')
#    doc.elements.each("articles/article") do |article|
#      @titles << article.elements['title'].text
#    end
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
