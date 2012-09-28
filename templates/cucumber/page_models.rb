require 'rails'

if Rails.root.present?
  page_models_path = Rails.root.join("features/support/page_models/**/*.rb")

  Dir[page_models_path].each do |page_model|
    require page_model
  end
end
