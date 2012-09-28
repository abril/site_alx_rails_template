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

add_source "http://gems.abrdigital.com.br"

gem 'newrelic_rpm'

gem "site_engine"
gem 'seed_pot'
gem "zapt_in"

gem 'site_helpers-chamada'
gem 'site_helpers-materia'
gem 'site_helpers-video'

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

comment_lines "config/application.rb", /active_record/

comment_lines "config/environments/development.rb", /active_record/

remove_file 'config/database.yml'

gsub_file "config/routes.rb", /^\s*#.*\n/, ""
gsub_file "config/environments/test.rb", /^\s*#.*\n/, ""
gsub_file "config/environments/production.rb", /^\s*#.*\n/, ""

duplicate_file "config/environments/development.rb", "config/environments/dev.rb"
duplicate_file "config/environments/production.rb", "config/environments/qa.rb"
duplicate_file "config/environments/production.rb", "config/environments/stage.rb"

application(nil, :env => "development") do
  "
  config.after_initialize do
    ActionController::Base.asset_host = lambda { |file,request| \"\#{request.scheme}://\#{request.host_with_port}\" }
  end
  "
end

get "https://raw.github.com/abril/mordor-rails_template/master/templates/site_engine.rb", "config/initializers/site_engine.rb"
get "https://raw.github.com/abril/mordor-rails_template/master/templates/pt-BR.yml", "config/locales/pt-BR.yml"
get "https://raw.github.com/abril/mordor-rails_template/master/templates/zapt_in.yml", "config/zapt_in.yml"
get_template "https://raw.github.com/abril/mordor-rails_template/master/templates/newrelic.yml", "config/newrelic.yml"

after_bundle do
  invoke "abril:devops:install"
  invoke "rspec:install"
  invoke "cucumber:install"

  comment_lines "features/support/env.rb", /^(begin|\s+DatabaseCleaner|rescue|\s+raise|end|Cucumber::Rails::Database.javascript)/
  gsub_file "features/support/env.rb", /^\s*#.*\n/, ""

  %w[driver failfast page_models restfulie vcr].each do |cucumber_file|
    get "https://raw.github.com/abril/mordor-rails_template/master/templates/cucumber/#{cucumber_file}.rb", "features/support/#{cucumber_file}.rb"
  end
  %w[headless hostname].each do |cucumber_file|
    get_template "https://raw.github.com/abril/mordor-rails_template/master/templates/cucumber/#{cucumber_file}.rb", "features/support/#{cucumber_file}.rb"
  end

  create_file "features/support/page_models/.gitkeep"
end
