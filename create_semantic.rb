require 'rubygems'
require 'rdf'
require 'rdf/ntriples'
require "rdf/rdfxml"
require 'rexml/document'

include RDF

########################################################################
#                                                                      #
#          Benchmarking                                                #
#          It takes from 21:10:08 to 21:15:26 to load all movies       #
#          It takes from 21:15:26 to 21:25:15 to load all TV shows     #
#          It takes from 21:25:15 to 21:26:08 to populate the graph    #
#          It takes from 21:26:08 to 21:26:41 to save the NT file      #
#                                                                      #
########################################################################

puts "#{Time.now}\tShall we start?"

persons = []
  actors = []
  creators = []
  directors = []
shows = []
  movies = []
  tvshows = []
articles = []
genres = []
networks = []
franchises = []
    
########################################################################
#                                                                      #
#          Load all XML data to memory                                 #
#                                                                      #
########################################################################

#doc = REXML::Document.new File.new('data/articles.xml')
#doc.elements.each("articles/article") do |a|
#  article = {}
#  article["title"] = a.elements['title'].text
#  article["uri"] = article["title"].gsub(/[^A-z0-9]/,'')
#  article["description"] = a.elements["description"].text
#  article["link"] = a.elements["link"].text
#  article["date"] = a.elements["date"].text
#  articles << article
#end

#articles.each do |article|
#  graph << [data[article["uri"]], RDF.type, WS.Article]
#  graph << [data[article["uri"]], WS.hasTitle, article["title"]]
#  graph << [data[article["uri"]], WS.hasDescription, article["description"]]
#  graph << [data[article["uri"]], WS.hasLink, article["link"]]
#  graph << [data[article["uri"]], WS.hasDate, article["date"]]
#end

# Movies
puts "#{Time.now}\tLoading from movies.xml"
doc = REXML::Document.new File.new('data/tests/movies.xml')
i = 0
doc.elements.each("movies/movie") do |m|
  i += 1
  #break if i == 100
  movie = {}
  movie["title"] = m.elements['name'].text
  movie["uri"] = movie["title"].gsub(/[^A-z0-9]/,'')
  # Franchise
  begin
    franchise = {}
    franchise["name"] = m.elements['franchise'].text
    franchise["uri"] = franchise["name"].gsub(/[^A-z0-9]/,'')
    franchises << franchise unless franchises.index(franchise)
    movie["franchise"] = franchise
  rescue
  end
  # Directors
  movie["directors"] = []
  m.elements.each("directors/director") do |director_name|
    director = {}
    director["name"] = director_name.text
    director["uri"] = director["name"].gsub(/[^A-z0-9]/,'')
    movie["directors"] << director
    directors << director unless directors.index(director)
  end
  # Genres
  movie["genres"] = []
  m.elements.each("genres/genre") do |genre_name|
    genre = {}
    genre["name"] = genre_name.text
    genre["uri"] = genre["name"].gsub(/[^A-z0-9]/,'')
    movie["genres"] << genre
    genres << genre unless genres.index(genre)
  end
  # Actors
  movie["actors"] = []
  m.elements.each("actors/actor") do |actor_name|
    actor = {}
    actor["name"] = actor_name.text
    actor["uri"] = actor["name"].gsub(/[^A-z0-9]/,'')
    movie["actors"] << actor
    actors << actor unless actors.index(actor)
  end
  movies << movie
end

# TV Shows
puts "#{Time.now}\tLoading from tvshows.xml"
doc = REXML::Document.new File.new('data/tests/tvshows.xml')
i = 0
doc.elements.each("tvshows/tvshow") do |t|
  i += 1
  #break if i == 10
  tvshow = {}
  tvshow["title"] = t.elements['name'].text
  tvshow["uri"] = tvshow["title"].gsub(/[^A-z0-9]/,'')
  # Franchise
  begin
    network = {}
    network["name"] = t.elements['network'].text
    network["uri"] = network["name"].gsub(/[^A-z0-9]/,'')
    networks << network unless networks.index(network)
    tvshow["network"] = network
  rescue
  end
  # Creators
  tvshow["creators"] = []
  t.elements.each("creators/creator") do |creator_name|
    creator = {}
    creator["name"] = creator_name.text
    creator["uri"] = creator["name"].gsub(/[^A-z0-9]/,'')
    tvshow["creators"] << creator
    creators << creator unless creators.index(creator)
  end
  # Genres
  tvshow["genres"] = []
  t.elements.each("genres/genre") do |genre_name|
    genre = {}
    genre["name"] = genre_name.text
    genre["uri"] = genre["name"].gsub(/[^A-z0-9]/,'')
    tvshow["genres"] << genre
    genres << genre unless genres.index(genre)
  end
  # Actors
  tvshow["actors"] = []
  t.elements.each("actors/actor") do |actor_name|
    actor = {}
    actor["name"] = actor_name.text
    actor["uri"] = actor["name"].gsub(/[^A-z0-9]/,'')
    tvshow["actors"] << actor
    actors << actor unless actors.index(actor)
  end
  tvshows << tvshow
end

########################################################################
#                                                                      #
#          Populate the semantic graph                                 #
#                                                                      #
########################################################################

puts "#{Time.now}\tPopulating the semantic graph"

# Actors
actors.each do |actor|
  graph << [data[actor["uri"]], RDF.type, WS.Actor]
  graph << [data[actor["uri"]], WS.hasName, actor["name"]]
end

# Creators
creators.each do |creator|
  graph << [data[creator["uri"]], RDF.type, WS.Creator]
  graph << [data[creator["uri"]], WS.hasName, creator["name"]]
end

# Directors
directors.each do |director|
  graph << [data[director["uri"]], RDF.type, WS.Director]
  graph << [data[director["uri"]], WS.hasName, director["name"]]
end

# Genres
genres.each do |genre|
  graph << [data[genre["uri"]], RDF.type, WS.Genre]
  graph << [data[genre["uri"]], WS.hasName, genre["name"]]
end

# Franchises
franchises.each do |franchise|
  graph << [data[franchise["uri"]], RDF.type, WS.Franchise]
  graph << [data[franchise["uri"]], WS.hasName, franchise["name"]]
end

# Networks
networks.each do |network|
  graph << [data[network["uri"]], RDF.type, WS.Network]
  graph << [data[network["uri"]], WS.hasName, network["name"]]
end

# Movies
movies.each do |movie|
  graph << [data[movie["uri"]], RDF.type, WS.Movie]
  graph << [data[movie["uri"]], WS.hasTitle, movie["title"]]
  if movie["franchise"] != nil and movie["franchise"].size > 0
    graph << [data[movie["uri"]], WS.hasFranchise, data[movie["franchise"]["uri"]]]
    graph << [data[movie["franchise"]["uri"]], WS.isFranchiseOf, data[movie["uri"]]]
  end
  movie["genres"].each do |genre|
    graph << [data[movie["uri"]], WS.hasGenre, data[genre["uri"]]]
    graph << [data[genre["uri"]], WS.isGenreOf, data[movie["uri"]]]
  end
  movie["directors"].each do |director|
    graph << [data[movie["uri"]], WS.hasDirector, data[director["uri"]]]
    graph << [data[director["uri"]], WS.isDirectorOf, data[movie["uri"]]]
  end
  movie["actors"].each do |actor|
    graph << [data[movie["uri"]], WS.hasActor, data[actor["uri"]]]
    graph << [data[actor["uri"]], WS.isActorIn, data[movie["uri"]]]
  end
end

# TV Shows
tvshows.each do |tvshow|
  graph << [data[tvshow["uri"]], RDF.type, WS.TVShow]
  graph << [data[tvshow["uri"]], WS.hasTitle, tvshow["title"]]
  if tvshow["network"] != nil and tvshow["network"].size > 0
    graph << [data[tvshow["uri"]], WS.hasNetwork, data[tvshow["network"]["uri"]]]
    graph << [data[tvshow["network"]["uri"]], WS.isNetworkOf, data[tvshow["uri"]]]
  end
  tvshow["genres"].each do |genre|
    graph << [data[tvshow["uri"]], WS.hasGenre, data[genre["uri"]]]
    graph << [data[genre["uri"]], WS.isGenreOf, data[tvshow["uri"]]]
  end
  tvshow["creators"].each do |creator|
    graph << [data[tvshow["uri"]], WS.hasCreator, data[creator["uri"]]]
    graph << [data[creator["uri"]], WS.isCreatorOf, data[tvshow["uri"]]]
  end
  tvshow["actors"].each do |actor|
    graph << [data[tvshow["uri"]], WS.hasActor, data[actor["uri"]]]
    graph << [data[actor["uri"]], WS.isActorIn, data[tvshow["uri"]]]
  end
end

########################################################################
#                                                                      #
#          Save it to N-Triples file                                   #
#                                                                      #
########################################################################

c = graph.count
puts "#{Time.now}\tSaving it to RDF file (#{c})"
i = 0
RDF::Writer.open("data/tests/graph.nt") do |writer|
  graph.each_statement do |stm|
    writer << stm
    i += 1
    print "#{Time.now}\t#{i}/#{c} - #{c-i}\n"
  end
end

puts "#{Time.now}\tAll done! (#{c})"
