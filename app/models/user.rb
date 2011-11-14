class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      auth.each { |key, value| logger.info "#{key}: #{value}" }
      auth['info'].each { |key, value| logger.info "#{key}: #{value}" }
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['name']
    end
  end
end
