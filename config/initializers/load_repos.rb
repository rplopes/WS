if Rails.env.production?
	TRIPLE_STORE =  RDF::DataObjects::Repository.new('postgres://susxgkmcos:cip7T9ZvmiKFZSYzn0pJ@ec2-107-22-249-232.compute-1.amazonaws.com/susxgkmcos')
else 
	TRIPLE_STORE =  RDF::DataObjects::Repository.new('sqlite3:triple_store.db')
end
REPOSITORY = RDF::Repository.new << TRIPLE_STORE
#Article.rebuild_index