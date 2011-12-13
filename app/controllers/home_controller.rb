require 'rexml/document'
require 'rss'
require "rdf"
require "rdf/ntriples"
require "rdf/do"
require "do_sqlite3"

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
    @articles = []
    
    # Aqui vai fazer @news = Articles.get_recent(10), por exemplo
    @articles = Article.all
    
  end
  
  def browse
    @page_title = "Browse"
  end
  
  def search
    @search = params[:search]
    @page_title = "Results for \"#{@search}\""
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
