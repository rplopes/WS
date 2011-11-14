class HomeController < ApplicationController
  def index
    if current_user
      user
    end
  end
  
  private
  
  def user
    @user = FbGraph::User.me OAUTH_ACCESS_TOKEN
  end
end
