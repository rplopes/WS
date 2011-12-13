class Article < ActiveRecord::Base
	acts_as_ferret :fields => [:title, :description, :author]

end






# uri: 			string
# title: 		string
# link: 		string
# description: 	text
# date: 		date
# creator: 		string
# source: 		string