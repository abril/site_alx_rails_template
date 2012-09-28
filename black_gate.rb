add_source "http://gems.abrdigital.com.br"

gem "site_engine", "~> 1.1.1"
gem 'seed_pot', '~> 0.2.2'
gem 'newrelic_rpm'

gem 'site_helpers-chamada', "~> 0.0.1"
gem 'site_helpers-materia', "~> 0.1.4"
gem 'site_helpers-models', "~> 0.0.2"
gem 'site_helpers-video', "~> 0.0.1"

gem_group :development, :test do
  gem "mordor-devops"
  gem 'step-up'
  gem 'rspec-rails'
  gem 'vcr'
  gem 'jasmine'
  gem 'headless'
  gem 'rally_rest_api'
end

gem_group :test do
  gem "cucumber-rails"
  gem "selenium-webdriver"
  gem 'webmock'
  gem "capybara"
  gem "curb"
end

append_file "Rakefile", "
task :test => [:spec, :'jasmine:ci', :cucumber]

Rake::Task[:default].clear_prerequisites
task :default => [:test]"

gsub_file "config/application.rb", %r{require 'rails/all'}, %{require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"}

gsub_file "config/application.rb", %r{    # config.i18n.default_locale = :de}, '    config.i18n.default_locale = :"pt-BR"'

remove_file 'config/database.yml'

gsub_file "config/routes.rb", /^\s*#.*\n/, ""

application(nil, :env => "development") do
  #config.after_initialize do
  #  ActionController::Base.asset_host = lambda { |file,request| "#{request.scheme}://#{request.host_with_port}" }
  #end
  "config.asset_host = 'http://localhost:3000'"
end

#get "dealgumlugar", "site_engine"

#class Rails::Generators::AppBase
#  def run_bundle
#    puts 'bundlado'
#  end
#end
