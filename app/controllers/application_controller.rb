class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user

  def WS
    RDF::Vocabulary.new("http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#")
  end

  def data
    RDF::Vocabulary.new("http://ws2011.herokuapp.com/semantic/")
  end

  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def query(query_string)
		SPARQL::Grammar.parse(query_string).execute(REPOSITORY)
	end 

  def insert_article(article, results)
    results[:people].each do |result|
      subject = RDF::Term.new article.uri
      predicate = WS.talksAboutPerson
      object = RDF::Term.new result[:x]
      TRIPLE_STORE << [subject, predicate, object]
      REPOSITORY << [subject, predicate, object]
    end
    results[:shows].each do |result|
      subject = RDF::Term.new article.uri
      predicate = WS.talksAboutShow
      object = RDF::Term.new result[:x]
      TRIPLE_STORE << [subject, predicate, object]
      REPOSITORY << [subject, predicate, object]
    end
  end
end
