require 'rexml/document'
require 'rss'
require 'sxp'
require "rdf"
require "rdf/ntriples"
require 'sparql/client'

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
    
    r = RDF::Repository.load("data/tests/graph.nt")
    rss = RSS::Parser.parse(open("http://feeds.ign.com/ignfeeds/tv").read, false)
    @news = []
    rss.items.each do |article|
      if article.title.index(":")
        title = article.title[0..article.title.index(":")-1].gsub('"', '\"')
        query = "SELECT *
                 WHERE { ?x <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#hasTitle> \"#{title}\" }"
        sse = SPARQL::Grammar.parse(query)
        sxp = sse.to_sxp
        results = sse.execute(r)
        if results.size > 0
          puts article.description
          @news << {:article => article, :show => results.last}
        end
      end
    end
    @news.each do |new|
      puts "#{new[:article].title} #{new[:show][:x]}"
    end
    
#    doc = REXML::Document.new File.new('data/articles.xml')
#    doc.elements.each("articles/article") do |article|
#      @titles << article.elements['title'].text
#    end
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
