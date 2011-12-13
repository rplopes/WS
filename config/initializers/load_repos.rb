TRIPLE_STORE =  RDF::DataObjects::Repository.new('sqlite3:triple_store.db')
REPOSITORY = RDF::Repository.new << TRIPLE_STORE
Article.rebuild_index