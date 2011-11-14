class DashboardController < ApplicationController
  FB_APP_ID     = '224485027617110'
  FB_APP_SECRET = '9c53e8c753494b0a49bddf138a17e1b8'
  
  def index
    if Rails.env.production?
      @graph   = Koala::Facebook::API.new(Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies))
      @user    = @graph.get_object('me')
      @likes   = @graph.get_connections('me', 'likes')
      @movies  = @likes.select{ |like| like['category'] === 'Movie'}
      @tvshows = @likes.select{ |like| like['category'] === 'Tv show'}
    else
      @graph   = Koala::Facebook::API.new()
      @user    = @graph.get_object('ricardopintolopes')
      #@likes   = @graph.get_connections('ricardopintolopes', 'likes')
    end
  end

  def auth
    session[:facebook_token] = oauth.get_access_token(params['code'])
    redirect_to root_path
  end

  private

  def authenticated?
    session[:facebook_token] or not Rails.env.production?
  end

#  def require_authentication
#    redirect_to oauth.url_for_oauth_code
#  end

  def graph_api_client
    Koala::Facebook::API.new(session[:facebook_token])
  end

  def rest_api_client
    Koala::Facebook::RestAPI.new(session[:facebook_token])
  end

  def oauth
    Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET, callback_url)
  end

#  def callback_url
#    'http://ws2011.herokuapp.com/'
#  end
end
