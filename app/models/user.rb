class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      logger.info auth
      user.provider = auth['provider']
      logger.info auth['provider']
      user.uid = auth['uid']
      user.name = auth['user_info']['name']
    end
  end
end
