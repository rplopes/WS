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
end
