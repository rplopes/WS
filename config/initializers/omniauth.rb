Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '224485027617110', '9c53e8c753494b0a49bddf138a17e1b8'
  OmniAuth.config.full_host = "https://www.facebook.com/connect/login_success.html" unless Rails.env.production?
end
