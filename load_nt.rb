require "rubygems"
require "rdf"
require "rdf/ntriples"

uri = RDF::URI.new "http://ws2010.herokuapp.com/"

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

puts "#{Time.now}\tLoading"
graph = RDF::Graph.load("data/graph.nt")
puts "#{Time.now}\tLoaded\n"

show = "The Big Bang Theory"

suggestions = []
graph.query([nil, hasTitle, show]) do |statement|
  graph.query([statement.subject, hasActor, nil]) do |statement2|
    graph.query([statement2.object, hasName, nil]) do |statement3|
      puts "#{Time.now}\t#{statement3.object} is actor in:"
      graph.query([statement3.subject, isActorIn, nil]) do |statement4|
        graph.query([statement4.object, hasTitle, nil]) do |statement5|
          if statement5.subject != statement.subject
            puts "#{Time.now}\t\t#{statement5.object}"
            suggestions << statement5 unless suggestions.index(statement5)
          end
        end
      end
    end
  end
end

puts "\nSuggestions for \"#{show}\" fans:"
suggestions.each do |suggestion|
  puts "#{suggestion.object}"
end
