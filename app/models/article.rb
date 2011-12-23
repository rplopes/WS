class Article < ActiveRecord::Base
	if Rails.env.development?
		acts_as_ferret :fields => [:title, :description, :creator]
	end
end






# uri: 			string
# title: 		string
# link: 		string
# description: 	text
# date: 		date
# creator: 		string
# source: 		string
