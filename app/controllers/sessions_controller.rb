class SessionsController < ApplicationController
  def create
    begin
      auth = request.env["omniauth.auth"]
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
      session[:user_id] = user.id
      session[:omniauth] = auth
      redirect_to root_url, :notice => "Signed in!"
    rescue
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end
end
