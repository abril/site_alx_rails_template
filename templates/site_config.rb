if ["development", "cucumber", "test"].include?(Rails.env)
  require 'site_config/test'
  SiteConfig.env = 'dev'
end
