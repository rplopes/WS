class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user


  WS = RDF::Vocabulary.new("http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#")

  def data
    return RDF::Vocabulary.new("http://ws2011.herokuapp.com/semantic/")
  end

  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
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

  def insert_franchise(franchise)
    subject = RDF::URI.new data[franchise.gsub(/[^A-z0-9]/,'')]
    TRIPLE_STORE << [subject, RDF.type, WS.Franchise]
    REPOSITORY  <<  [subject, RDF.type, WS.Franchise]
    TRIPLE_STORE << [subject, WS.hasName, franchise]
    REPOSITORY  <<  [subject, WS.hasName, franchise]
  end

  def insert_genre(genre)
    subject = RDF::URI.new data[genre.gsub(/[^A-z0-9]/,'')]
    TRIPLE_STORE << [subject, RDF.type, WS.Genre]
    REPOSITORY  <<  [subject, RDF.type, WS.Genre]
    TRIPLE_STORE << [subject, WS.hasName, genre]
    REPOSITORY  <<  [subject, WS.hasName, genre]
  end

  def insert_director(director)
    subject = RDF::URI.new data[director.gsub(/[^A-z0-9]/,'')]
    TRIPLE_STORE << [subject, RDF.type, WS.Director]
    REPOSITORY  <<  [subject, RDF.type, WS.Director]
    TRIPLE_STORE << [subject, WS.hasName, director]
    REPOSITORY  <<  [subject, WS.hasName, director]
  end

  def insert_actor(actor)
    subject = RDF::URI.new data[actor.gsub(/[^A-z0-9]/,'')]
    TRIPLE_STORE << [subject, RDF.type, WS.Actor]
    REPOSITORY  <<  [subject, RDF.type, WS.Actor]
    TRIPLE_STORE << [subject, WS.hasName, actor]
    REPOSITORY  <<  [subject, WS.hasName, actor]
  end

  def insert_movie(title, franchise, genres, directors, actors)
    subject = RDF::URI.new data[title.gsub(/[^A-z0-9]/,'')]
    TRIPLE_STORE << [subject, RDF.type, WS.Movie]
    REPOSITORY  <<  [subject, RDF.type, WS.Movie]
    TRIPLE_STORE << [subject, WS.hasTitle, title]
    REPOSITORY  <<  [subject, WS.hasTitle, title]
    if franchise and franchise.size > 0
      franchise_url = RDF::URI.new data[franchise.gsub(/[^A-z0-9]/,'')]
      TRIPLE_STORE << [subject, WS.hasFranchise, franchise_url]
      REPOSITORY  <<  [subject, WS.hasFranchise, franchise_url]
      TRIPLE_STORE << [franchise_url, WS.isFranchiseOf, subject]
      REPOSITORY  <<  [franchise_url, WS.isFranchiseOf, subject]
    end
    genres.each do |genre|
      genre_url = RDF::URI.new data[genre.gsub(/[^A-z0-9]/,'')]
      TRIPLE_STORE << [subject, WS.hasGenre, genre_url]
      REPOSITORY  <<  [subject, WS.hasGenre, genre_url]
      TRIPLE_STORE << [genre_url, WS.isGenreOf, subject]
      REPOSITORY  <<  [genre_url, WS.isGenreOf, subject]
    end
    directors.each do |director|
      director_url = RDF::URI.new data[director.gsub(/[^A-z0-9]/,'')]
      TRIPLE_STORE << [subject, WS.hasDirector, director_url]
      REPOSITORY  <<  [subject, WS.hasDirector, director_url]
      REPOSITORY  <<  [director_url, WS.isDirectorOf, subject]
      TRIPLE_STORE << [director_url, WS.isDirectorOf, subject]
    end
    actors.each do |actor|
      actor_url = RDF::URI.new data[actor.gsub(/[^A-z0-9]/,'')]
      TRIPLE_STORE << [subject, WS.hasActor, actor_url]
      REPOSITORY  <<  [subject, WS.hasActor, actor_url]
      TRIPLE_STORE << [actor_url, WS.isActorIn, subject]
      REPOSITORY  <<  [actor_url, WS.isActorIn, subject]
    end
  end

end