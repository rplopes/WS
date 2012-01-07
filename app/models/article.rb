class Article < ActiveRecord::Base
	if Rails.env.development?
		acts_as_ferret :fields => [:title, :description, :creator]
	end

	self.per_page = 2
end






# uri: 			string
# title: 		string
# link: 		string
# description: 	text
# date: 		date
# creator: 		string
# source: 		string
