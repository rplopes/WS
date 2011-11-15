class HomeController < ApplicationController
  def index
    if current_user
      user
    end
  end
  
  private
  
  def user
    @user = FbGraph::User.fetch(session[:user_id], :access_token => session[:omniauth]['credentials']['token'])
    #FbGraph::User.me(session[:omniauth]['credentials']['token'])
    @user = @user.fetch
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
