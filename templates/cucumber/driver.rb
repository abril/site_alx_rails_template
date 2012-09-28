require 'selenium/webdriver/remote/http/curb'

Capybara.register_driver :selenium_with_long_timeout do |app|
  client = Selenium::WebDriver::Remote::Http::Curb.new
  client.timeout = 60
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :http_client => client)
end

Capybara.default_driver = :selenium_with_long_timeout if ENV['APP_HOST'].present?
