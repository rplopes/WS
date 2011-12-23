require 'rexml/document'
require 'rss'
require "rdf"
require "rdf/ntriples"
require "rdf/do"
#require "do_sqlite3"

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

  def show
    @article = Article.find params[:id]
    @page_title = @article.title
    q = "SELECT *
         WHERE { <#{@article.uri}> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#talksAboutShow> ?x .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    @show_title = results.first[:name] if results.size > 0
  end
  
  def browse
    @page_title = "Browse"
  end
  
  def search_page
    @search = params[:search]
    @page_title = "Results for \"#{@search}\""
    search = @search.gsub('"', '\"')
    @articles = []
    keywords = @search.split(/ /)
    keywords.each do |keyword|
      if Rails.env.production?
        @articles += Article.search keyword
      else
        @articles += Article.find_with_ferret(keyword)
      end
    end
    @articles = @articles.uniq
    @it_is = search_is(search)
    render "home/search"
  end
  
  def semantic_search
    @search = params[:search]
    search = @search.gsub('"', '\"')
    it_is = search_is(search)
    return search_page unless it_is
    
    @page_title = "Results for the #{it_is} \"#{@search}\""
    @articles = []
    
    relations = get_relations_for_actor(search) if it_is.eql? "actor"
    relations = get_relations_for_director(search) if it_is.eql? "movies director"
    relations = get_relations_for_creator(search) if it_is.eql? "TV shows creator"
    relations = get_relations_for_movie(search) if it_is.eql? "movie"
    relations = get_relations_for_tvshow(search) if it_is.eql? "TV show"
    relations = get_relations_for_franchise(search) if it_is.eql? "franchise"
    relations = get_relations_for_network(search) if it_is.eql? "network"
    relations = get_relations_for_genre(search) if it_is.eql? "genre"
    
    relations.each do |relation|
      semantic_articles = []
      semantic_articles << get_news_of_actor(relation[:actor]) if relation[:actor]
      semantic_articles << get_news_of_tvshow(relation[:tvshow_uri]) if relation[:tvshow_uri]
      semantic_articles << get_news_of_tvshow(relation[:show_uri]) if relation[:show_uri]
      puts "->" + relation[:actor] if relation[:actor]
      if semantic_articles.size > 0
        semantic_articles[0].each do |sa|
          @articles << sa
        end
      end
    end
    
    render "home/search"
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

  def get_news_of_actor(uri)
    articles = []
    q = "SELECT *
         WHERE { ?article <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#talksAboutPerson> <#{uri}> }"
    results = query(q)
    puts q
    results.each do |result|
      puts result[:article]
      result = Article.find_by_uri(result[:article].to_s)
      puts result
      articles << result
    end
    puts articles.inspect
    return articles
  end

  def get_news_of_tvshow(uri)
    articles = []
    q = "SELECT *
         WHERE { ?article <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#talksAboutShow> <#{uri}> }"
    results = query(q)
    puts q
    results.each do |result|
      puts result[:article]
      result = Article.find_by_uri(result[:article].to_s)
      puts result
      articles << result
    end
    puts articles.inspect
    return articles
  end
  
  def get_relations_for_actor(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" }"
    results = query(q)
    relations = [{:actor_uri => results.last[:x], :name => search}]
    # Shows
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#isActorIn> ?show .
                 ?show <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:show_uri => result[:show], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_director(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" }"
    results = query(q)
    relations = [{:director_uri => results.last[:x], :name => search}]
    # Movies
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#isDirectorOf> ?movie .
                 ?movie <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:movie_uri => result[:movie], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_creator(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" }"
    results = query(q)
    relations = [{:creator_uri => results.last[:x], :name => search}]
    # Movies
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#isCreatorOf> ?tvshow .
                 ?tvshow <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:tvshow_uri => result[:tvshow], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_movie(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" }"
    results = query(q)
    relations = [{:movie_uri => results.last[:x], :name => search}]
    # Creators
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasDirector> ?director .
                 ?director <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:director_uri => result[:director], :name => result[:name]}
    end
    # Actors
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasActor> ?actor .
                 ?actor <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:actor_uri => result[:actor], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_tvshow(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" }"
    results = query(q)
    relations = [{:tvshow_uri => results.last[:x], :name => search}]
    # Creators
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasCreator> ?creator .
                 ?creator <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:creator_uri => result[:creator], :name => result[:name]}
    end
    # Actors
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasActor> ?actor .
                 ?actor <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:actor_uri => result[:actor], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_franchise(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" }"
    results = query(q)
    relations = [{:franchise_uri => results.last[:x], :name => search}]
    # Movies
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#isFranchiseOf> ?movie .
                 ?movie <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:movie_uri => result[:movie], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_network(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" }"
    results = query(q)
    relations = [{:network_uri => results.last[:x], :name => search}]
    # TV shows
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#isNetworkOf> ?tvshow .
                 ?tvshow <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:tvshow_uri => result[:tvshow], :name => result[:name]}
    end
    return relations
  end
  
  def get_relations_for_genre(search)
    # Self
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" }"
    results = query(q)
    relations = [{:genre_uri => results.last[:x], :name => search}]
    # Shows
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                 ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#isGenreOf> ?show .
                 ?show <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> ?name }"
    results = query(q)
    results.each do |result|
      relations << {:show_uri => result[:show], :name => result[:name]}
    end
    return relations
  end
  
  def search_is(search)
    it_is = nil
    
    # Is a movie?
    q = "SELECT *
         WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                 ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Movie> }"
    results = query(q)
    it_is = "movie" if results.size > 0
    
    # Is a TV show?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#TVShow> }"
      results = query(q)
      it_is = "TV show" if results.size > 0
    end
    
    # Is an actor?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Actor> }"
      results = query(q)
      it_is = "actor" if results.size > 0
    end
    
    # Is a director?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Director> }"
      results = query(q)
      it_is = "movies director" if results.size > 0
    end
    
    # Is a creator?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Creator> }"
      results = query(q)
      it_is = "TV shows creator" if results.size > 0
    end
    
    # Is a franchise?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Franchise> }"
      results = query(q)
      it_is = "franchise" if results.size > 0
    end
    
    # Is a network?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Network> }"
      results = query(q)
      it_is = "network" if results.size > 0
    end
    
    # Is a genre?
    unless it_is
      q = "SELECT *
           WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasName> \"#{search}\" .
                   ?x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#Genre> }"
      results = query(q)
      it_is = "genre" if results.size > 0
    end
    return it_is
  end
  
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
