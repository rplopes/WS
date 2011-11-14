class HomeController < ApplicationController
  def index
    if current_user
      user
    end
  end
  
  private
  
  def user
    @user = FbGraph::User.new('me', :access_token => session[:omniauth]['credentials']['token'])
    @user.fetch
  end
end
