class HomeController < ApplicationController

  def index
    if current_user
      user
    end
  end
  
  def latest_news
  end
  
  def browse
  end
  
  def search
  end
  
  def suggestions
  end
  
  private
  
  def user
    @user = FbGraph::User.me(session[:omniauth]['credentials']['token']).fetch
    @likes = @user.likes
    @movies = []
    @tvshows = []
    @likes.each do |like|
      @movies << like if like.category === 'Movie'
      @tvshows << like if like.category === 'Tv show'
    end
    logger.info @user
  end
end
