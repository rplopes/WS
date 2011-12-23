class CreateArticle < ActiveRecord::Migration
  def up
  	 create_table :articles do |t|
  	 	t.string  :uri
  	 	t.string  :title
  	 	t.string  :link
  	 	t.text  :description
  	 	t.date    :date
  	 	t.string  :creator
  	 	t.string  :source
    end
  end

  def down
  	drop_table :articles
  end
end
