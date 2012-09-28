require 'headless'
<% magic_number = app_name.each_byte.to_a.inject(0) { |sum, v| sum += v } %>
display = ENV['APP_HOST'].present? ? <%= 100 + magic_number %> : <%= 101 + magic_number %>
headless = Headless.new(:display => display)
headless.start
