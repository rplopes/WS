Ws::Application.routes.draw do
  
  root :to => "home#index"
  
  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
  match "/news" => "home#latest_news"
  match "/browse" => "home#browse"
  match "/search" => "home#search_page"
  match "/ssearch" => "home#semantic_search"
  match "/suggestions" => "home#suggestions"
  match "/article/:id" => "home#show"
  
  match "/fetcher/get_news" => "fetcher#get_news"

  match "/fetcher/test_movies" => "fetcher#test_movies"
  match "/fetcher/test_tvshows" => "fetcher#test_tvshows"
  match "/fetcher/test_directors" => "fetcher#test_directors"
  match "/fetcher/test_creators" => "fetcher#test_creators"
  match "/fetcher/test_actors" => "fetcher#test_actors"
  match "/fetcher/test_genres" => "fetcher#test_genres"
  match "/fetcher/test_networks" => "fetcher#test_networks"
  match "/fetcher/test_franchises" => "fetcher#test_franchises"
end
