require 'fileutils'

def duplicate_file(source, destination)
  say_status :duplicate_file, destination
  FileUtils.copy source, destination
end

def get_template(source_url, destination)
  get(source_url) do |content|
    context = instance_eval('binding')
    erb = ERB.new(content, nil, '-', '@output_buffer').result(context)
    content.gsub!(/^.+$/m, erb)
    destination
  end
end

class Rails::Generators::AppBase
  alias :run_bundle_original :run_bundle

  def after_bundle(&block)
    (@after_bundle ||= []) << block if block_given?
  end

  def run_bundle
    run_bundle_original
    @after_bundle.each { |block| block.call } if defined?(@after_bundle)
  end
end

comment_lines "Gemfile", /sqlite3/
comment_lines "Gemfile", /coffee-rails/
comment_lines "Gemfile", /coffee-rails/
comment_lines "Gemfile", %r{group :assets do
  gem 'sass-rails',   '~> 3.2.3'

  gem 'uglifier', '>= 1.0.3'
end}

add_source "http://gems.abrdigital.com.br"

gem 'newrelic_rpm'

gem "site_engine", ">= 2.2.2"

gem_group :development, :test do
  gem "mordor-devops"
  gem "alexandria_boilerplate", ">= 0.0.3"
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

gsub_file("app/controllers/application_controller.rb", /class ApplicationController < ActionController::Base/mi) do
  <<-EOS.gsub(/^  /, '')
  class ApplicationController < ActionController::Base
    before_filter do
      response.headers["Vary"] = "X-Device"
    end
  EOS
end

comment_lines "config/application.rb", /config.assets.enabled/

comment_lines "config/application.rb", /active_record/

comment_lines "config/environments/development.rb", /active_record/
comment_lines "config/environments/test.rb", /active_record/

remove_file 'config/database.yml'

gsub_file "Gemfile", /^\s*#.*\n/, ""
gsub_file "config/routes.rb", /^\s*#.*\n/, ""
gsub_file "config/environments/test.rb", /^\s*#.*\n/, ""
gsub_file "config/environments/production.rb", /^\s*#.*\n/, ""

duplicate_file "config/environments/development.rb", "config/environments/dev.rb"
duplicate_file "config/environments/production.rb", "config/environments/qa.rb"
duplicate_file "config/environments/production.rb", "config/environments/stage.rb"

remove_file "README.rdoc"
remove_dir "app/assets"
remove_dir "app/helpers"
remove_dir "app/mailers"
remove_dir "app/models"
remove_dir "app/views"
remove_dir "db"
remove_dir "lib/assets"
remove_file "public/404.html"
remove_file "public/422.html"
remove_file "public/500.html"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_dir "test"
remove_dir "vendor"

application(nil, :env => "development") do
  "
  config.after_initialize do
    ActionController::Base.asset_host = lambda { |file,request| \"\#{request.scheme}://\#{request.host_with_port}\" }
  end
  "
end

get "https://raw.github.com/abril/site_alx_rails_template/master/templates/site_config.rb", "config/initializers/site_engine.rb"
get "https://raw.github.com/abril/site_alx_rails_template/master/templates/README.md", "README.md"
get "https://raw.github.com/abril/site_alx_rails_template/master/templates/pt-BR.yml", "config/locales/pt-BR.yml"
get "https://raw.github.com/abril/site_alx_rails_template/master/templates/abrio.yml", "config/abrio.yml"
get_template "https://raw.github.com/abril/site_alx_rails_template/master/templates/newrelic.yml", "config/newrelic.yml"

after_bundle do
  generate "abril:devops:install", app_name
  generate "rspec:install"
  generate "cucumber:install"
  generate "alexandria_boilerplate:boilerplate", app_name
  generate "site_engine:structure"

  comment_lines "features/support/env.rb", /^(begin|\s+DatabaseCleaner|rescue|\s+raise|end|Cucumber::Rails::Database.javascript)/
  gsub_file "features/support/env.rb", /^\s*#.*\n/, ""

  %w[driver failfast page_models restfulie vcr].each do |cucumber_file|
    get "https://raw.github.com/abril/site_alx_rails_template/master/templates/cucumber/#{cucumber_file}.rb", "features/support/#{cucumber_file}.rb"
  end
  %w[headless hostname].each do |cucumber_file|
    get_template "https://raw.github.com/abril/site_alx_rails_template/master/templates/cucumber/#{cucumber_file}.rb", "features/support/#{cucumber_file}.rb"
  end

  create_file "features/support/page_models/.gitkeep"

  comment_lines "spec/spec_helper.rb", /^\s*config\.(fixture|use_transactional|infer_base_class)/
  gsub_file "spec/spec_helper.rb", /^\s*#.*\n/, ""
  %w[restfulie vcr].each do |rspec_file|
    get "https://raw.github.com/abril/site_alx_rails_template/master/templates/rspec/#{rspec_file}.rb", "spec/support/#{rspec_file}.rb"
  end
end
