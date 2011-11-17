require 'rubygems'
require 'rdf'
require 'rdf/ntriples'
require 'rexml/document'

graph = RDF::Graph.new

uri = RDF::URI.new "http://ws2010.herokuapp.com/"

#=================================================
# declaração dos nomes das propriedades e relações
#=================================================
name        = uri.join("name")
title       = uri.join("title")
content     = uri.join("content")
actorIn     = uri.join("actorIn")
hasActor    = uri.join("hasActor")
directorOf  = uri.join("directorOf")
hasDirector = uri.join("hasDirector")


#=================================================
# actors.xml -> triples
#=================================================
actors = []
actors_uri = uri.join("actors/")

doc = REXML::Document.new File.new('actors.xml')

doc.elements.each("actors/actor/name") do |actor_name|  
  actor_uri = actors_uri.join(actor_name.text.gsub(/[^A-z0-9]/,''))  
  graph << [actor_uri, name, actor_name.text]

  actors << {:name => actor_name.text, :uri => actor_uri}
end

#graph.query([nil, name, nil]).each_object do |name|
#  puts name
#end

#=================================================
# directors.xml -> triples
#=================================================
directors_uri = uri.join("directors/")

doc = REXML::Document.new File.new('directors.xml')

doc.elements.each("directors/director/name") do |director_name|
  director_uri = directors_uri.join(director_name.text.gsub(/[^A-z0-9]/,''))  
  graph << [director_uri, name, director_name.text]
end

#graph.query([nil, name, nil]).each_object do |name|
#  puts name
#end

#=================================================
# creators.xml -> triples
#=================================================
#creators_uri = uri.join("creators")

#doc = REXML::Document.new File.new('creators.xml')

#doc.elements.each("creators/creator/name") do |creator_name|
#  creator_uri = creator_uri.join(creator_name.text.gsub(/\s/,''))
#  graph << [creator_uri, name, creator_name.text]
#end

#graph.query([nil, name, nil]).each_object do |name|
#  puts name
#end

#=================================================
# movies.xml -> triples
#=================================================
movies_uri = uri.join("movies/")

doc = REXML::Document.new File.new('movies.xml')

doc.elements.each("movies/movie") do |movie|
  movie_title = movie.elements["name"] 
  movie_uri = movies_uri.join(movie_title.text.gsub(/[^A-z0-9]/,''))
  graph << [movie_uri, title, movie_title.text]
  movie.elements.each("actors/actor") do |actor_name|
    actor_uri = actors_uri.join(actor_name.text.gsub(/[^A-z0-9]/,''))  
    graph << [actor_uri, actorIn, movie_uri]
    graph << [movie_uri, hasActor, actor_uri]
  end
  movie.elements.each("directors/director") do |director_name|
    director_uri = directors_uri.join(director_name.text.gsub(/[^A-z0-9]/,''))  
    graph << [director_uri, directorOf, movie_uri]
    graph << [movie_uri, hasDirector, director_uri]
  end
end

#=================================================
# shows.xml -> triples
#=================================================
tvshows_uri = uri.join("tvshows/")

doc = REXML::Document.new File.new('shows.xml')

doc.elements.each("tvshows/tvshow") do |tvshow|
  tvshow_title = tvshow.elements["name"] 
  tvshow_uri = tvshows_uri.join(tvshow_title.text.gsub(/[^A-z0-9]/,''))
  graph << [tvshow_uri, title, tvshow_title.text]
  tvshow.elements.each("actors/actor") do |actor_name|
    actor_uri = actors_uri.join(actor_name.text.gsub(/[^A-z0-9]/,''))  
    graph << [actor_uri, actorIn, tvshow_uri]
    graph << [tvshow_uri, hasActor, actor_uri]
  end
  tvshow.elements.each("creators/creator") do |creator_name|
    creator_uri = creators_uri.join(creator_name.text.gsub(/[^A-z0-9]/,''))  
    graph << [creator_uri, creatorOf, tvshow_uri]
    graph << [tvshow_uri, hasCreator, creator_uri]
  end
end

#=================================================
# articles.xml -> triples
#=================================================
articles_uri = uri.join("articles/")

doc = REXML::Document.new File.new('articles.xml')
doc.elements.each("articles/article") do |article|
  article_title = article.elements["title"]
  article_uri = articles_uri.join(article_title.text.gsub(/[^A-z0-9]/,''))

  #===============================================
  # classifica
  #===============================================
  actors.each do |actor|
    if article_title.text =~ /.*#{actor[:name]}.*/
      graph << [article_uri, hasActor, actor[:uri]]    
    end
  end
  #===============================================

  graph << [article_uri, title, article_title.text]
  article_content = article.elements["description"]
  graph << [article_uri, content, article_content.text]
end

#=================================================
# nome dos actores e directores que participam no filme The Godfather
#=================================================
#puts "================================="
#puts "Movie: THE GODFATHER"
#puts "================================="
#graph.query([nil, name, "The Godfather"]).each_subject do |movie_uri|
#  puts "Actors:"
#  puts "================================="
#  graph.query([movie_uri, hasActor, nil]).each_object do |actor_uri|
#    graph.query([actor_uri, name, nil]).each_object do |actor_name|
#      puts actor_name    
#    end  
#  end
#  puts "================================="  
#  puts "Directors:"
#  puts "================================="
#  graph.query([movie_uri, hasDirector, nil]).each_object do |director_uri|
#    graph.query([director_uri, name, nil]).each_object do |director_name|
#      puts director_name    
#    end  
#  end
#end
#puts "================================="

#=================================================
# titulo e descrição das noticias relacionadas com o Benicio Del Toro
#=================================================
#puts "================================="
#puts "Actor: Benicio Del Toro"
#puts "================================="
graph.query([nil, name, "Benicio Del Toro"]).each_subject do |actor_uri|
  graph.query([nil, hasActor, actor_uri]).each_subject do |article_uri|
    if article_uri.parent == articles_uri
      puts "================================="
      puts "Title:"
      puts "================================="
      graph.query([article_uri, title, nil]).each_object do |article_title|
        puts article_title    
      end
      puts "================================="
      puts "Content:"
      puts "================================="
      graph.query([article_uri, content, nil]).each_object do |article_content|
        puts article_content
      end
      puts "================================="
    end
  end
end
