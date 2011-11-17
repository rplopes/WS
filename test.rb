require "rubygems"
require "rdf"
require "rdf/ntriples"

graph = RDF::Graph.new

bradpitt = RDF::URI.new("http://something/actor/BradPitt")
angelina = RDF::URI.new("http://something/actor/AngelinaJolie")

mrandmrssmith = RDF::URI.new("http://something/movie/MrAndMrsSmith")

name     = RDF::URI.new("http://something#name")
actorIn  = RDF::URI.new("http://something#actorIn")
hasActor = RDF::URI.new("http://something#hasactor")

graph << [bradpitt, name, "Brad Pitt"]
graph << [angelina, name, "Angelina Jolie"]

graph << [mrandmrssmith, name, "Mr And Mrs Smith"]

graph << [bradpitt, actorIn, mrandmrssmith]
graph << [mrandmrssmith, hasActor, bradpitt]
graph << [angelina, actorIn, mrandmrssmith]
graph << [mrandmrssmith, hasActor, angelina]

graph.query([nil, actorIn, mrandmrssmith]) do |statement|
  graph.query([statement.subject, name, nil]) do |statement2|
    puts statement2.object.inspect  
  end
end
