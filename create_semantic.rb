require 'rubygems'
require 'rdf'
require 'rdf/ntriples'
require 'rexml/document'

graph = RDF::Graph.new

uri = RDF::URI.new "http://ws2010.herokuapp.com/"

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

actors_uri     = "actors/"
directors_uri  = "directors/"
creators_uri   = "creators/"
persons_uri    = "persons/"
movies_uri     = "movies/"
tvshows_uri    = "tvshows/"
shows_uri      = "shows/"
articles_uri   = "articles/"
genres_uri     = "genres/"
networks_uri   = "networks/"
franchises_uri = "franchises/"

hasName        = uri.join("hasName")
hasTitle       = uri.join("hasTitle")
hasContent     = uri.join("hasContent")
hasDate        = uri.join("hasDate")
hasLink        = uri.join("hasLink")

hasRelation      = uri.join("hasRelation")
  hasFranchise   = uri.join("hasFranchise")
  hasGenre       = uri.join("hasGenre")
  hasNetwork     = uri.join("hasNetwork")
  hasPerson      = uri.join("hasPerson")
    hasActor     = uri.join("hasActor")
    hasCreator   = uri.join("hasCreator")
    hasDirector  = uri.join("hasDirector")

isRelatedTo      = uri.join("isRelatedTo")
  isFranchiseOf  = uri.join("isFranchiseOf")
  isGenreOf      = uri.join("isGenreOf")
  isNetworkOf    = uri.join("isNetworkOf")
  isPersonIn     = uri.join("isPersonIn")
    isActorIn    = uri.join("isActorIn")
    isCreatorOf  = uri.join("isCreatorOf")
    isDirectorOf = uri.join("isDirectorOf")

talksAbout                  = uri.join("talksAbout")
  talksAboutPerson          = uri.join("talksAboutPerson")
    talksAboutActor         = uri.join("talksAboutActor")
    talksAboutCreator       = uri.join("talksAboutCreator")
    talksAboutDirector      = uri.join("talksAboutDirector")
  talksAboutShow            = uri.join("talksAboutShow")
    talksAboutMovie         = uri.join("talksAboutMovie")
    talksAboutTVShow        = uri.join("talksAboutTVShow")

isTalkedAboutIn             = uri.join("isTalkedAboutIn")
  isPersonTalkedAboutIn     = uri.join("isPersonTalkedAboutIn")
    isActorTalkedAboutIn    = uri.join("isActorTalkedAboutIn")
    isCreatorTalkedAboutIn  = uri.join("isCreatorTalkedAboutIn")
    isDirectorTalkedAboutIn = uri.join("isDirectorTalkedAboutIn")
  isShowTalkedAboutIn       = uri.join("isShowTalkedAboutIn")
    isMovieTalkedAboutIn    = uri.join("isMovieTalkedAboutIn")
    isTVShowTalkedAboutIn   = uri.join("isTVShowTalkedAboutIn")
    
########################################################################
#                                                                      #
#          Load all XML data to memory                                 #
#                                                                      #
########################################################################

# Movies
doc = REXML::Document.new File.new('data/movies.xml')
doc.elements.each("movies/movie") do |m|
  movie = {}
  movie["title"] = m.elements['name'].text
  movie["uri"] = movies_uri + movie["title"].gsub(/[^A-z0-9]/,'')
  # Franchise
  franchise_name = m.elements['franchise']
  begin
    franchise = {:uri => (franchises_uri + franchise_name.text.gsub(/[^A-z0-9]/,'')), :name => franchise_name}
    franchises << franchise unless franchises.index(franchise)
    movie["franchise"] = franchise
  rescue
  end
  # Directors
  movie["directors"] = []
  m.elements.each("directors/director") do |director_name|
    director = {:uri => (directors_uri + director_name.text.gsub(/[^A-z0-9]/,'')), :name => director_name}
    movie["directors"] << director
    directors << director unless directors.index(director)
  end
  # Genres
  movie["genres"] = []
  m.elements.each("genres/genre") do |genre_name|
    genre = {:uri => (genres_uri + genre_name.text.gsub(/[^A-z0-9]/,'')), :name => genre_name}
    movie["genres"] << genre
    genres << genre unless genres.index(genre)
  end
  # Actors
  movie["actors"] = []
  m.elements.each("actors/actor") do |actor_name|
    actor = {:uri => (actors_uri + actor_name.text.gsub(/[^A-z0-9]/,'')), :name => actor_name}
    movie["actors"] << actor
    actors << actor unless actors.index(actor)
  end
  movies << movie
  puts movies.count
end

# TV Shows
doc = REXML::Document.new File.new('data/tvshows.xml')
doc.elements.each("tvshows/tvshow") do |t|
  tvshow = {}
  tvshow["title"] = t.elements['name'].text
  tvshow["uri"] = tvshows_uri + tvshow["title"].gsub(/[^A-z0-9]/,'')
  # Network
  network_name = t.elements['network']
  begin
    network = {:uri => (networks_uri + network_name.text.gsub(/[^A-z0-9]/,'')), :name => network_name}
    networks << network unless neworks.index(network)
    movie["network"] = network
  rescue
  end
  # Creators
  tvshow["creators"] = []
  t.elements.each("creators/creator") do |creator_name|
    creator = {:uri => (creators_uri + creator_name.text.gsub(/[^A-z0-9]/,'')), :name => creator_name}
    tvshow["creators"] << creator
    creators << creator unless creators.index(creator)
  end
  # Genres
  tvshow["genres"] = []
  t.elements.each("genres/genre") do |genre_name|
    genre = {:uri => (genres_uri + genre_name.text.gsub(/[^A-z0-9]/,'')), :name => genre_name}
    tvshow["genres"] << genre
    genres << genre unless genres.index(genre)
  end
  # Actors
  tvshow["actors"] = []
  t.elements.each("actors/actor") do |actor_name|
    actor = {:uri => (actors_uri + actor_name.text.gsub(/[^A-z0-9]/,'')), :name => actor_name}
    tvshow["actors"] << actor
    actors << actor unless actors.index(actor)
  end
  tvshows << tvshow
  puts tvshows.count
end

puts "finished"
