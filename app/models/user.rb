class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      logger.info auth
      user.name = auth["user_info"]["name"]
    end
  end
end
