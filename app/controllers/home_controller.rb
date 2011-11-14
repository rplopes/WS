class HomeController < ApplicationController
  def index
    if current_user
      user
    end
  end
  
  private
  
  def user
    @user = FbGraph::User.me(session[:omniauth]['credentials']['token'])
    @user = @user.fetch
    @likes = @user.likes
    logger.info @user
  end
end
