require "rubygems"
require "rdf"
require "rdf/ntriples"
require "rdf/rdfxml"
require 'sparql/grammar'

queryable = RDF::Repository.load("data/graph.nt")

titles = ["How I Met Your Mother",
          "The Big Bang Theory",
          "Inception"]
r = []

titles.each do |title|
  query = "PREFIX ws: <http://www.semanticweb.org/ontologies/2011/10/moviesandtv.owl#>
  SELECT ?name ?title
  WHERE
    { ?x ws:hasTitle \"#{title}\" .
      ?x ws:hasActor ?y .
      ?y ws:hasName ?name .
      ?y ws:isActorIn ?z .
      ?z ws:hasTitle ?title
    }"
  sse = SPARQL::Grammar.parse(query)
  results = sse.execute(queryable)

  results.each do |result|
    reccomendation = {:show => result[:title].to_s, :actor => result[:name].to_s, :from => title}
    r << reccomendation unless r.index(reccomendation) or reccomendation[:show].eql? title
  end
end

puts "Suggested shows:"
r.each do |rec|
  puts "- #{rec[:show]} (includes #{rec[:actor]} from #{rec[:from]})"
end
