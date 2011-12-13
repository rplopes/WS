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
    @articles = []
    
    search = @search.gsub('"', '\"')
    @it_is = nil
    
    # Is a movie?
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                 ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Movie> }"
    results = query(q)
    @it_is = "the movie" if results.size > 0
    
    # Is a TV show?
    unless @it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#TVShow> }"
      results = query(q)
      @it_is = "the TV show" if results.size > 0
    end
    
    # Is an actor?
    unless @it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Actor> }"
      results = query(q)
      @it_is = "the actor" if results.size > 0
    end
    
    # Is a director?
    unless @it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Director> }"
      results = query(q)
      @it_is = "the movies director" if results.size > 0
    end
    
    # Is a creator?
    unless @it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Creator> }"
      results = query(q)
      @it_is = "the TV shows creator" if results.size > 0
    end
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
