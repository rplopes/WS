require 'rubygems'
require 'rdf'
require 'rdf/ntriples'
require 'rexml/document'

########################################################################
#                                                                      #
#          Benchmarking                                                #
#          It takes from 21:10:08 to 21:15:26 to load all movies       #
#          It takes from 21:15:26 to 21:25:15 to load all TV shows     #
#          It takes from 21:25:15 to 21:26:08 to populate the graph    #
#          It takes from 21:26:08 to 21:26:41 to save the NT file      #
#                                                                      #
########################################################################

graph = RDF::Graph.new

uri = RDF::URI.new "http://ws2010.herokuapp.com/"

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
#          Onthology data definitions                                  #
#                                                                      #
########################################################################

actors_uri     = uri + "actors/"
directors_uri  = uri + "directors/"
creators_uri   = uri + "creators/"
persons_uri    = uri + "persons/"
movies_uri     = uri + "movies/"
tvshows_uri    = uri + "tvshows/"
shows_uri      = uri + "shows/"
articles_uri   = uri + "articles/"
genres_uri     = uri + "genres/"
networks_uri   = uri + "networks/"
franchises_uri = uri + "franchises/"

hasName        = RDF::URI.new(uri + "hasName")
hasTitle       = RDF::URI.new(uri + "hasTitle")
hasContent     = RDF::URI.new(uri + "hasContent")
hasDate        = RDF::URI.new(uri + "hasDate")
hasLink        = RDF::URI.new(uri + "hasLink")

hasRelation      = RDF::URI.new(uri + "hasRelation")
  hasFranchise   = RDF::URI.new(uri + "hasFranchise")
  hasGenre       = RDF::URI.new(uri + "hasGenre")
  hasNetwork     = RDF::URI.new(uri + "hasNetwork")
  hasPerson      = RDF::URI.new(uri + "hasPerson")
    hasActor     = RDF::URI.new(uri + "hasActor")
    hasCreator   = RDF::URI.new(uri + "hasCreator")
    hasDirector  = RDF::URI.new(uri + "hasDirector")

isRelatedTo      = RDF::URI.new(uri + "isRelatedTo")
  isFranchiseOf  = RDF::URI.new(uri + "isFranchiseOf")
  isGenreOf      = RDF::URI.new(uri + "isGenreOf")
  isNetworkOf    = RDF::URI.new(uri + "isNetworkOf")
  isPersonIn     = RDF::URI.new(uri + "isPersonIn")
    isActorIn    = RDF::URI.new(uri + "isActorIn")
    isCreatorOf  = RDF::URI.new(uri + "isCreatorOf")
    isDirectorOf = RDF::URI.new(uri + "isDirectorOf")

talksAbout                  = RDF::URI.new(uri + "talksAbout")
  talksAboutPerson          = RDF::URI.new(uri + "talksAboutPerson")
    talksAboutActor         = RDF::URI.new(uri + "talksAboutActor")
    talksAboutCreator       = RDF::URI.new(uri + "talksAboutCreator")
    talksAboutDirector      = RDF::URI.new(uri + "talksAboutDirector")
  talksAboutShow            = RDF::URI.new(uri + "talksAboutShow")
    talksAboutMovie         = RDF::URI.new(uri + "talksAboutMovie")
    talksAboutTVShow        = RDF::URI.new(uri + "talksAboutTVShow")

isTalkedAboutIn             = RDF::URI.new(uri + "isTalkedAboutIn")
  isPersonTalkedAboutIn     = RDF::URI.new(uri + "isPersonTalkedAboutIn")
    isActorTalkedAboutIn    = RDF::URI.new(uri + "isActorTalkedAboutIn")
    isCreatorTalkedAboutIn  = RDF::URI.new(uri + "isCreatorTalkedAboutIn")
    isDirectorTalkedAboutIn = RDF::URI.new(uri + "isDirectorTalkedAboutIn")
  isShowTalkedAboutIn       = RDF::URI.new(uri + "isShowTalkedAboutIn")
    isMovieTalkedAboutIn    = RDF::URI.new(uri + "isMovieTalkedAboutIn")
    isTVShowTalkedAboutIn   = RDF::URI.new(uri + "isTVShowTalkedAboutIn")
    
########################################################################
#                                                                      #
#          Load all XML data to memory                                 #
#                                                                      #
########################################################################

# Movies
puts "#{Time.now}\tLoading from movies.xml"
doc = REXML::Document.new File.new('data/movies.xml')
doc.elements.each("movies/movie") do |m|
  movie = {}
  movie["title"] = m.elements['name'].text
  movie["uri"] = RDF::URI.new(movies_uri + movie["title"].gsub(/[^A-z0-9]/,''))
  # Franchise
  franchise_name = m.elements['franchise']
  begin
    franchise = {}
    franchise["name"] = franchise_name.text
    franchise["uri"] = RDF::URI.new(franchises_uri + franchise["name"].gsub(/[^A-z0-9]/,''))
    franchises << franchise unless franchises.index(franchise)
    movie["franchise"] = franchise
  rescue
  end
  # Directors
  movie["directors"] = []
  m.elements.each("directors/director") do |director_name|
    director = {}
    director["name"] = director_name.text
    director["uri"] = RDF::URI.new(directors_uri + director["name"].gsub(/[^A-z0-9]/,''))
    movie["directors"] << director
    directors << director unless directors.index(director)
  end
  # Genres
  movie["genres"] = []
  m.elements.each("genres/genre") do |genre_name|
    genre = {}
    genre["name"] = genre_name.text
    genre["uri"] = RDF::URI.new(genres_uri + genre["name"].gsub(/[^A-z0-9]/,''))
    movie["genres"] << genre
    genres << genre unless genres.index(genre)
  end
  # Actors
  movie["actors"] = []
  m.elements.each("actors/actor") do |actor_name|
    actor = {}
    actor["name"] = actor_name.text
    actor["uri"] = RDF::URI.new(actors_uri + actor["name"].gsub(/[^A-z0-9]/,''))
    movie["actors"] << actor
    actors << actor unless actors.index(actor)
  end
  movies << movie
end

# TV Shows
puts "#{Time.now}\tLoading from tvshows.xml"
doc = REXML::Document.new File.new('data/tvshows.xml')
doc.elements.each("tvshows/tvshow") do |t|
  tvshow = {}
  tvshow["title"] = t.elements['name'].text
  tvshow["uri"] = RDF::URI.new(tvshows_uri + tvshow["title"].gsub(/[^A-z0-9]/,''))
  # Network
  network_name = t.elements['network']
  begin
    network = {}
    network["name"] = network_name.text
    network["uri"] = RDF::URI.new(networks_uri + network["name"].gsub(/[^A-z0-9]/,''))
    networks << network unless neworks.index(network)
    movie["network"] = network
  rescue
  end
  # Creators
  tvshow["creators"] = []
  t.elements.each("creators/creator") do |creator_name|
    creator = {}
    creator["name"] = creator_name.text
    creator["uri"] = RDF::URI.new(creators_uri + creator["name"].gsub(/[^A-z0-9]/,''))
    tvshow["creators"] << creator
    creators << creator unless creators.index(creator)
  end
  # Genres
  tvshow["genres"] = []
  t.elements.each("genres/genre") do |genre_name|
    genre = {}
    genre["name"] = genre_name.text
    genre["uri"] = RDF::URI.new(genres_uri + genre["name"].gsub(/[^A-z0-9]/,''))
    tvshow["genres"] << genre
    genres << genre unless genres.index(genre)
  end
  # Actors
  tvshow["actors"] = []
  t.elements.each("actors/actor") do |actor_name|
    actor = {}
    actor["name"] = actor_name.text
    actor["uri"] = RDF::URI.new(actors_uri + actor["name"].gsub(/[^A-z0-9]/,''))
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
  graph << [actor["uri"], hasName, actor["name"]]
end

# Creators
creators.each do |creator|
  graph << [creator["uri"], hasName, creator["name"]]
end

# Directors
directors.each do |director|
  graph << [director["uri"], hasName, director["name"]]
end

# Genres
genres.each do |genre|
  graph << [genre["uri"], hasName, genre["name"]]
end

# Franchises
franchises.each do |franchise|
  graph << [franchise["uri"], hasName, franchise["name"]]
end

# Networks
networks.each do |network|
  graph << [network["uri"], hasName, network["name"]]
end

# Movies
movies.each do |movie|
  graph << [movie["uri"], hasTitle, movie["title"]]
  if movie["franchise"] != nil and movie["franchise"].size > 0
    graph << [movie["uri"], hasFranchise, movie["franchise"]["uri"]]
    graph << [movie["franchise"]["uri"], isFranchiseOf, movie["uri"]]
  end
  movie["genres"].each do |genre|
    graph << [movie["uri"], hasGenre, genre["uri"]]
    graph << [genre["uri"], isGenreOf, movie["uri"]]
  end
  movie["directors"].each do |director|
    graph << [movie["uri"], hasDirector, director["uri"]]
    graph << [director["uri"], isDirectorOf, movie["uri"]]
  end
  movie["actors"].each do |actor|
    graph << [movie["uri"], hasActor, actor["uri"]]
    graph << [actor["uri"], isActorIn, movie["uri"]]
  end
end

# TV Shows
tvshows.each do |tvshow|
  graph << [tvshow["uri"], hasTitle, tvshow["title"]]
  if tvshow["network"] != nil and tvshow["network"].size > 0
    graph << [tvshow["uri"], hasNetwork, tvshow["network"]["uri"]]
    graph << [tvshow["network"]["uri"], isNetworkOf, tvshow["uri"]]
  end
  tvshow["genres"].each do |genre|
    graph << [tvshow["uri"], hasGenre, genre["uri"]]
    graph << [genre["uri"], isGenreOf, tvshow["uri"]]
  end
  tvshow["creators"].each do |creator|
    graph << [tvshow["uri"], hasCreator, creator["uri"]]
    graph << [creator["uri"], isCreatorOf, tvshow["uri"]]
  end
  tvshow["actors"].each do |actor|
    graph << [tvshow["uri"], hasActor, actor["uri"]]
    graph << [actor["uri"], isActorIn, tvshow["uri"]]
  end
end

########################################################################
#                                                                      #
#          Save it to N-Triples file                                   #
#                                                                      #
########################################################################

puts "#{Time.now}\tSaving it to N-Triples file"
RDF::Writer.open("data/graph.nt") do |writer|
  writer << graph
end

puts "#{Time.now}\tAll done!"
