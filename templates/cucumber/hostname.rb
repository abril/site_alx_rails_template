Capybara.server_port = <%= 4000 + app_name.each_byte.to_a.inject(0) { |sum, v| sum += v } %>
Capybara.app_host    = ENV['APP_HOST'] || "http://local.<%= app_name %>.abril.com.br:#{Capybara.server_port}"
Capybara.run_server  = ENV['APP_HOST'].nil?
