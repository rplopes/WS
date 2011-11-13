class DashboardController < ApplicationController
  FB_APP_ID     = '224485027617110'
  FB_APP_SECRET = '9c53e8c753494b0a49bddf138a17e1b8'

  def index
    if authenticated?
      @user    = graph_api_client.get_object('me')
      @friends = graph_api_client.get_connections('me', 'friends')

      friend_ids = @friends.collect { |friend| friend['id'] }
      @genders   = rest_api_client.rest_call('users.getInfo', {:uids => friend_ids, :fields => 'sex'})

      @males   = @genders.count{ |friend| friend['sex'] == 'male'}
      @females = @genders.size - @males
    else
      require_authentication
    end
  end

  def auth
    session[:facebook_token] = oauth.get_access_token(params['code'])
    redirect_to root_path
  end

  private

  def authenticated?
    session[:facebook_token]
  end

  def require_authentication
    redirect_to oauth.url_for_oauth_code
  end

  def graph_api_client
    Koala::Facebook::GraphAPI.new(session[:facebook_token])
  end

  def rest_api_client
    Koala::Facebook::RestAPI.new(session[:facebook_token])
  end

  def oauth
    Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET, callback_url)
  end

  def callback_url
    'http://localhost:3000/auth'
  end
end
